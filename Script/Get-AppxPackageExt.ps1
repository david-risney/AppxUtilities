param([string] $Filter,
	[switch] $MergeType);

$packages = ($input | %{ $_; } | ?{ $_; });

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

	$appxPackage = $_;
	$outputObject = $_;
	if (!$MergeType) {
		$outputObject = New-Object PSObject `
			| Add-Member PackageFullName $appxPackage.PackageFullName -PassThru `
			| Add-Member Package $appxPackage -PassThru `
		;
	}

	($outputObject `
		| Add-Member DisplayName $displayName -PassThru `
		| Add-Member ApplicationIds $applicationIds -PassThru `
		| Add-Member InstallLocationItem $installLocationItem -PassThru `
		| Add-Member Manifest $manifestAsXml -PassThru `
		| Add-Member InstallTimeUtc $installTimeUtc
		);

	$outputObject;
}
