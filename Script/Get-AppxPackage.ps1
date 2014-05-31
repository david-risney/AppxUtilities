$packages = ($input | %{ $_; });

if (!$packages) {
	$packages = Get-AppxPackage;
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
		$manifestAsXml = [xml](gc $installLocationItem.GetFiles("appxmanifest.xml").fullname)
		$displayName = (select-xml -xml $manifestAsXml -xpath "/appx:Package/appx:Properties/appx:DisplayName" -namespace @{appx="http://schemas.microsoft.com/appx/2010/manifest"}).Node."#text"
		$applicationIds = (@() + (select-xml -xml $manifestAsXml -xpath "//appx:Application/@Id" -namespace @{appx="http://schemas.microsoft.com/appx/2010/manifest"})) | 
			%{ $_.Node."#text" }
	}

    ($_ `
        | add-member DisplayName $displayName -PassThru `
        | add-member ApplicationIds $applicationIds -PassThru `
        | add-member InstallLocationItem $installLocationItem -PassThru `
        | add-member Manifest $manifestAsXml -PassThru `
        | add-member InstallTimeUtc $installTimeUtc
        );

    $_;
}
