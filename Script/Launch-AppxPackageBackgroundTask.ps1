<#
.SYNOPSIS
    Launch an Appx package's registered background task.
.DESCRIPTION
    Given a background task id, launch the corresponding registered background
    task.
.PARAMETER BackgroundTaskId
    The GUID of the registered background task to launch. This may be obtained by
    examining the BackgroundTaskIds.id property on the result of Get-AppxPackageExt.
    Alternatively, you may pass in the result of Get-AppxPackageExt as pipeline input to 
    Launch-AppxPackageBackgroundTask and the first registered background task of
    the package will be launched. Or you may provide an entry from (Get-AppxPackageExt).BackgroundTaskIds and the corresponding background task will be launched. 
    Or you may provide the background task ID GUID as a string as pipeline input.
.PARAMETER MergeType
    Usually the results output are of a custom PSObject type that cannot be
    fed into pre-existing PowerShell Appx commands. MergeType will instead
    use the pre-existing PowerShell types and attach new properties (that
    will not be displayed by the existing type) to the existing types.
.EXAMPLE
    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask*
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {@{Name=SampleJavaScriptBackgroundTask; Id={A2D67B9C-80A3-4C0D-877D-10AE2915E597}}}
    InstallTimeUtc      : 6/26/2014 4:27:12 PM
    
    
    
    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask* | Launch-AppxPackageBackgroundTask
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
param([string] $BackgroundTaskId,
	[switch] $MergeType);

$merge = !!$MergeType;

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}

$allInput = @($input | %{ $_; }) + @($BackgroundTaskId) | ?{ $_; };

$allInput | %{ 
	$in = $_;
	# Upgrade results from builtin Get-AppxPackage to results from AppxUtilities Get-AppxPackage.ps1
	if ($in.PackageFullName -and !($in | Get-Member BackgroundTasks)) {
		$in = Get-AppxPackage | where PackageFullName -match $in.PackageFullName | .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType;
	}
	if ($in.PackageFullName -and ($in | Get-Member BackgroundTasks)) {
		$in = $in.BackgroundTasks[0];
	}
	if ($in.Name -and $in.Id) {
		$in = $in.Id;
	}
	if ($in.GetType().Name -eq "string" -and $in[0] -eq "{" -and $in[$in.length - 1] -eq "}") {
		$in = $in.Substring(1, $in.length - 2);
	}

	.(ScriptDir("LaunchAppxPackageBackgroundTask.exe")) /launch $in;
};
