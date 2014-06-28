<#
.SYNOPSIS
    Terminate all processes for a particular Appx package.
.DESCRIPTION
    Terminate all processes for a particular Appx package.
.PARAMETER PackageFullNames
    The list of PackageFullNames of the Appx package's the processes of which
    should be acted upon. This is either a string or the result of calling 
    Get-AppxPackageExt. This is also accepted as pipeline input.
.PARAMETER MergeType
    Usually the results output are of a custom PSObject type that cannot be
    fed into pre-existing PowerShell Appx commands. MergeType will instead
    use the pre-existing PowerShell types and attach new properties (that
    will not be displayed by the existing type) to the existing types.
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
	[switch] $WaitForCompletion);

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}


$PackageFullNames + $input | %{ $_; } | ?{ $_; } | %{
	$PackageFullName = $_;

	if ($PackageFullName.GetType() -ne "string") {
		$PackageFullName = $PackageFullName.PackageFullName;
	}

	if ($WaitForCompletion) {
		.(ScriptDir("PackageExecutionState.exe")) /terminateAndWait $PackageFullName;
	}
	else {
		.(ScriptDir("PackageExecutionState.exe")) /terminate $PackageFullName;
	}

	.(ScriptDir("Get-AppxPackageExt.ps1")) $PackageFullName;
}
