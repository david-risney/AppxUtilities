param([object[]] $PackageFullNames,
    [string] $OnLaunch,
	[string] $On,
    [switch] $Off)

$PackageFullNames + $input | %{
	$PackageFullName = $_;
	$ProcessId = $null;
	if ($PackageFullName.GetType() -ne "string") {
		$ProcessId = $PackageFullName.Id;
		$PackageFullName = $PackageFullName.PackageFullName;
	}

    if ($Off) {
        [void](plmdebug /disableDebug $PackageFullName); 
    }
    else {
		if ($OnLaunch) {
			[void](plmdebug /enableDebug $PackageFullName $OnLaunch);
		}
		else {
			[void](plmdebug /enableDebug $PackageFullName);
			if ($On -and $ProcessId) {
				.$On -p $ProcessId;
			}
		}
    }

	$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
	.($myPath + "\Get-AppxPackage.ps1") | where PackageFullName -match $PackageFullName;
}
