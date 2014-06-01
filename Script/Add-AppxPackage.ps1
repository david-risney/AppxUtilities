param([object[]] $Paths,
    [switch] $Force,
    [switch] $PassThru);

$PackagesAdded = @();

$Paths + $input | %{
	$Path = $_;
	if ($Path.GetType() -eq "FileInfo") {
		$Path = $Path.FullName;
	}

	$before = get-appxpackage;

	$lastError = (add-appxpackage $Path 2>&1);

	if ($lastError -and ($error.CategoryInfo.Category -eq "ResourceExists") -and $Force) {
		$errorPrefix = "Deployment of package ";
		$lastError.Exception.Message.Split("`n") | ?{ $_ -match "Deployment of package" } | %{ $_ -replace "Deployment of package ([^ ]*).*","`$1" } | %{
			remove-appxpackage $_
			$before = get-appxpackage;
			add-appxpackage $Path;
		}
	}
	elseif ($lastError) {
		$lastError;
	}

	$after = get-appxpackage;

	$PackagesAdded += @(diff $before $after | where SideIndicator -eq "=>" | %{ $_.InputObject })
}

if ($PassThru) {
	$PackagesAdded;
}