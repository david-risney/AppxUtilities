param([string[]] $PackageFullNames,
    [string] $OnLaunch,
    [switch] $Off)

$PackageFullNames + $input | %{
	$PackageFullName = $_;
	if ($PackageFullName.GetType() -ne "string") {
		$PackageFullName = $PackageFullName.PackageFullName;
	}

    if ($Off) {
        plmdebug /disableDebug $PackageFullName; 
    }
    else {
        plmdebug /enableDebug $PackageFullName $OnLaunch;
    }
}
