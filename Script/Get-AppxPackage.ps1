param([string] $Filter);

$packages = ($input | %{ $_; });

if (!$packages) {
	if ($Filter) {
		$packages = Get-AppxPackage $Filter;
	}
	else {
		$packages = Get-AppxPackage;
	}
}

$packages | %{
	$installLocationItem = $null;
	$installTimeUtc = $null;
	$manifestAsXml = $null;
	$displayName = $null;
	$applicationIds = @();

	if ($_.InstallLocation -and (Test-Path $_.InstallLocation)) {
		$installLocationItem = (gi $_.InstallLocation);
		$installTimeUtc = $installLocationItem.CreationTimeUtc;
		$manifestAsXml = Get-AppxPackageManifest -Package $_.PackageFullName;
		$displayName = (select-xml -xml $manifestAsXml -xpath "/appx:Package/appx:Properties/appx:DisplayName" -namespace @{appx="http://schemas.microsoft.com/appx/2010/manifest"}).Node."#text"
		$applicationIds = (@() + (select-xml -xml $manifestAsXml -xpath "//appx:Application/@Id" -namespace @{appx="http://schemas.microsoft.com/appx/2010/manifest"})) | 
			%{ $_.Node."#text" };
		$applicationIds = @() + $applicationIds; # Make sure its an array even if there's only one element.
	}

    ($_ `
        | add-member DisplayName $displayName -PassThru `
        | add-member ApplicationIds $applicationIds -PassThru `
        | add-member InstallLocationItem $installLocationItem -PassThru `
        | add-member Manifest $manifestAsXml -PassThru `
        | add-member InstallTimeUtc $installTimeUtc
        );

    $_ | select Name,DisplayName,PackageFullName,ApplicationIds,InstallLocationItem,InstallTimeUtc;
}
