param([object[]] $Paths,
	[switch] $Force);

$PackagesAdded = @();

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}

$Paths + $input | %{
	$Path = $_;
	if ($Path.GetType() -eq "FileInfo") {
		$Path = $Path.FullName;
	}

	$before = .(ScriptDir("Get-AppxPackageExt.ps1"));

	$lastError = (Add-AppxPackage $Path 2>&1);

	if ($lastError -and ($error.CategoryInfo.Category -eq "ResourceExists") -and $Force) {
		$errorPrefix = "Deployment of package ";
		$lastError.Exception.Message.Split("`n") | ?{ $_ -match "Deployment of package" } | %{ $_ -replace "Deployment of package ([^ ]*).*","`$1" } | %{
			remove-appxpackage $_
			$before = .(ScriptDir("Get-AppxPackageExt.ps1"));
			add-appxpackage $Path;
		}
	}
	elseif ($lastError) {
		$lastError;
	}

	$after = .(ScriptDir("Get-AppxPackageExt.ps1"));

	$PackagesAdded += @(diff $before $after | where SideIndicator -eq "=>" | %{ $_.InputObject })
}

$PackagesAdded;
