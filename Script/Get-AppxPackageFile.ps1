<#
.SYNOPSIS
    Get Appx package info from an Appx package file.
.DESCRIPTION
    Given an Appx package file, Get-AppxPackageFile extracts the manifest from
    the file (using ExtractFromAppx.exe) and outputs the results of 
    Get-AppxPackageExt filtered to packages with the same name as that in the
    manifest, or if none exist outputs information from the manifest.
.PARAMETER PackagePath
    The paths to the appx package files. These can be FileInfo objects or 
    strings that are the absolute paths. This is also the pipeline input.
.PARAMETER MergeType
    Usually the results output are of a custom PSObject type that cannot be
    fed into pre-existing PowerShell Appx commands. MergeType will instead
    use the pre-existing PowerShell types and attach new properties (that
    will not be displayed by the existing type) to the existing types.
.EXAMPLE
    PS C:\Users\Dave> Get-AppxPackageFile.ps1 .\BackgroundTask.Windows_1.0.0.0_AnyCPU_Debug.appx
    
    
    Name                  : Microsoft.SDKSamples.BackgroundTask.JS
    DisplayName           : BackgroundTask JS sample
    Version               : 1.0.0.0
    Publisher             : CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US
    ProcessorArchitecture : neutral
    ApplicationIds        : {App}
    Manifest              : #document
    
    
    Results of calling for a package not installed
.EXAMPLE
    PS C:\Users\Dave> Get-AppxPackageFile.ps1 .\BackgroundTask.Windows_1.0.0.0_AnyCPU_Debug.appx
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 2:53:15 PM
    
    Results of calling for a package installed
.LINK
    Add-AppxPackageExt.ps1
.LINK
    Debug-AppxPackage.ps1
.LINK
    Get-AppxPackageExt.ps1
.LINK
    Get-AppxPackageFile.ps1
.LINK
    Get-ProcessAppxPackage.ps1
.LINK
    Launch-AppxPackage.ps1
.LINK
    Launch-AppxPackageBackgroundTask.ps1
.LINK
    Resume-AppxPackage.ps1
.LINK
    Suspend-AppxPackage.ps1
.LINK
    Terminate-AppxPackage.ps1
#>
param([object[]] $PackagePath,
	[switch] $MergeType);

$merge = !!$MergeType;

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}


$PackagePath + $input | ?{ $_ } | %{
	$path = $_;
	if ($path.GetType().Name -ne "String") {
		$path = $path.FullName;
	}

	$manifestAsXml = [xml](.(ScriptDir("\ExtractFromAppx.exe")) $path "AppxManifest.xml");
	$installedPackages = .(ScriptDir("\Get-AppxPackageExt.ps1")) -MergeType:$merge $manifestAsXml.Package.Identity.Name;

	if ($installedPackages) {
		$installedPackages;
	}
	else {
		$id = $manifestAsXml.Package.Identity;
		$displayName = (select-xml -xml $manifestAsXml -xpath "/*[local-name() = 'Package']/*[local-name() = 'Properties']/*[local-name() = 'DisplayName']" ).Node."#text"
		$applicationIds = (@() + (select-xml -xml $manifestAsXml -xpath "//*[local-name() = 'Application']/@Id" )) | 
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
