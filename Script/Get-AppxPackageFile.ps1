param([object[]] $PackagePath);

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path))

$PackagePath + $input | ?{ $_ } | %{
	$path = $_;
	if ($path.GetType().Name -ne "String") {
		$path = $path.FullName;
	}

	$manifestAsXml = [xml](.($myPath + "\ExtractFromAppx.exe") $path "AppxManifest.xml");
	$installedPackages = .($myPath + "\Get-AppxPackage.ps1") $manifestAsXml.Package.Identity.Name;

	if ($installedPackages) {
		$installedPackages;
	}
	else {
		$id = $manifestAsXml.Package.Identity;
		$displayName = (select-xml -xml $manifestAsXml -xpath "/appx:Package/appx:Properties/appx:DisplayName" -namespace @{appx="http://schemas.microsoft.com/appx/2010/manifest"}).Node."#text"
		$applicationIds = (@() + (select-xml -xml $manifestAsXml -xpath "//appx:Application/@Id" -namespace @{appx="http://schemas.microsoft.com/appx/2010/manifest"})) | 
			%{ $_.Node."#text" };
		$applicationIds = @() + $applicationIds; # Make sure its an array even if there's only one element.
		
    (new-object PSObject `
        | add-member Name $id.Name -PassThru `
        | add-member DisplayName $displayName -PassThru `
        | add-member Version $id.Version -PassThru `
        | add-member Publisher $id.Publisher -PassThru `
        | add-member ProcessorArchitecture $id.ProcessorArchitecture -PassThru `
        | add-member ApplicationIds $applicationIds -PassThru `
        | add-member Manifest $manifestAsXml -PassThru `
        );
	}
}
