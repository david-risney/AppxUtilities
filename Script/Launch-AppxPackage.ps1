<#
.SYNOPSIS
    Launch an installed Appx package's application.
.DESCRIPTION
    Given an AppxPackage or PackageFamilyName and ApplicationId Launch-AppxPackage
    launches the application and provides as output the Get-ProcessAppxPackage
    result of the launched process.
.PARAMETER PackageFamilyName
    The PackageFamilyName of the application to launch. Must be called with a
    corresponding ApplicationId parameter. Alternatively provide the result of
    Get-AppxPackageExt as pipeline input and the first application of the package
    will be launched.
.PARAMETER ApplicationId
    The ApplicationId from the AppxPackage to launch. This can be obtained from
    getting the ApplicationIds array from Get-AppxPackageExt.ps1. Alternatively
    provide a string of the form "PackageFullName!ApplicationId" as pipeline
    input and it will be launched.
.PARAMETER MergeType
    Usually the results output are of a custom PSObject type that cannot be
    fed into pre-existing PowerShell Appx commands. MergeType will instead
    use the pre-existing PowerShell types and attach new properties (that
    will not be displayed by the existing type) to the existing types.
.EXAMPLE
    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask* | Launch-AppxPackage
    
    PackageFullName               State       ProcessName             Id
    ---------------               -----       -----------             --
    Microsoft.SDKSamples.Backg... running     WWAHost              10604
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
param([string] $PackageFamilyName,
	[string] $ApplicationId,
	[switch] $MergeType);

$merge = !!$MergeType;

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}

$ApplicationUserModelId = "";
if ($PackageFamilyName -and $ApplicationId) {
	$ApplicationUserModelId = $PackageFamilyName + "!" + $ApplicationId;
}

$allInput = @($input | %{ $_; }) + @($ApplicationUserModelId) | ?{ $_; };

$allInput | %{ 
	$in = $_;
	# Upgrade results from builtin Get-AppxPackage to results from AppxUtilities Get-AppxPackage.ps1
	if ($in.PackageFullName -and !($in.Package -and !$in.ApplicationIds)) {
		$in = Get-AppxPackage | where PackageFullName -match $in.PackageFullName | .(ScriptDir("Get-AppxPackageExt.ps1"));
	}

	$aumi = $in;
	if ($aumi.GetType().Name -ne "string") {
		$aumi = $in.Package.PackageFamilyName + "!" + $in.ApplicationIds[0];
	}
	$processId = (.(ScriptDir("LaunchAppxPackage.exe")) $aumi 2>&1);
	try {
		$processId = [int]$processId;
		.(ScriptDir("Get-ProcessAppxPackage.ps1")) $processId -MergeType:$merge ;
	}
	catch {
		throw $processId 
	}
};
