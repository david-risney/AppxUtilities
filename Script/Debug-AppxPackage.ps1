<#
.SYNOPSIS
    Debug appx packages.
.DESCRIPTION
    A wrapper for plmdebug.exe, this script makes it easy to use plmdebug.exe
    in PowerShell with other AppxPackage commands. Returns the 
    Get-AppxPackageExt results of the packages to which this command applied.
.PARAMETER PackageFullNames
    This parameter (or pipeline input) determines the set of processes or 
    packages to which to apply debugging. These are either a string containing
    the PackageFullName, the output from Get-AppxPackage, or 
    Get-AppxPackageExt, or the output from Get-ProcessAppxPackage.
.PARAMETER OnLaunch
    Set a command line to be executed as the debugger to attach to the 
    specified packages the next time any of those packages are launched.
.PARAMETER On
    Specify a command line to be executed as the debugger immediately for the
    processes specified in PackageFullNames after turning on debug mode for 
    the packages specified in PackageFullNames.

    Unlike the Off or OnLaunch, PackageFullNames must be the output of 
    Get-ProcessAppxPackage and not just a package full name string or the 
    output of Get-AppxPackageExt.
.PARAMETER Off
    Turn off debug mode for the packages specified in PackageFullNames.
.PARAMETER MergeType
    Usually the results output are of a custom PSObject type that cannot be
    fed into pre-existing PowerShell Appx commands. MergeType will instead
    use the pre-existing PowerShell types and attach new properties (that
    will not be displayed by the existing type) to the existing types.
.EXAMPLE
    PS C:\Users\Dave> Get-AppxPackageExt *BackgroundTask* | Debug-AppxPackage -OnLaunch "C:\debuggers\windbg.exe -server tcp:port=9100"
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM
    
    # Attach a debugger to a package the next time it is run using Debug-AppxPackage.
.EXAMPLE
    PS C:\Users\Dave> Get-ProcessAppxPackage *backgroundtask* | Debug-AppxPackage.ps1 -On C:\debuggers\windbg.exe
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM
    
    # Attach a debugger to a currently running package
.EXAMPLE
    PS C:\Users\Dave> Get-AppxPackageExt *backgroundtask* | Debug-AppxPackage.ps1 -Off
    
    
    PackageFullName     : Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    DisplayName         : BackgroundTask JS sample
    InstallLocationItem : C:\Program
                          Files\WindowsApps\Microsoft.SDKSamples.BackgroundTask.JS_1.0.0.0_neutral__8wekyb3d8bbwe
    Manifest            : #document
    ApplicationIds      : {App}
    BackgroundTasks     : {}
    InstallTimeUtc      : 6/26/2014 3:14:11 PM
    
    # Turn off debugging a package.
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
param([object[]] $PackageFullNames,
	[string] $OnLaunch,
	[string] $On,
	[switch] $Off,
	[switch] $MergeType)

$merge = !!$MergeType;

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}


$PackageFullNames + $input | %{
	$PackageFullName = $_;
	$ProcessId = $null;

	if ($PackageFullName.GetType() -ne "string") {
		$ProcessId = $PackageFullName.Id;
		$PackageFullName = $PackageFullName.PackageFullName;
	}

	if ($Off) {
		[void](.(ScriptDir("plmdebug.exe")) /disableDebug $PackageFullName); 
	}
	else {
		if ($OnLaunch) {
			[void](.(ScriptDir("plmdebug.exe")) /enableDebug $PackageFullName $OnLaunch);
		}
		else {
			[void](.(ScriptDir("plmdebug.exe")) /enableDebug $PackageFullName);
			if ($On -and $ProcessId) {
				.$On -p $ProcessId;
			}
		}
	}

	.(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge | where PackageFullName -match $PackageFullName;
}
