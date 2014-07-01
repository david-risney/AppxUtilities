<#
.SYNOPSIS
    Get Appx package info for running processes.

.DESCRIPTION
    A wrapper for Get-Process, this script provides information about the 
    running processes package identity and package execution state.

.PARAMETER ProcessFilter
    Filter the output using this to match either process ID, process name,
    or package name.

.PARAMETER All
    Display all processes in result even if they don't have package identity.

.PARAMETER MergeType
    Usually the results output are of a custom PSObject type that cannot be
    fed into pre-existing PowerShell Appx commands. MergeType will instead
    use the pre-existing PowerShell types and attach new properties (that
    will not be displayed by the existing type) to the existing types.

.EXAMPLE
    PS C:\Users\Dave> Get-ProcessAppxPackage
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    microsoft.windowscommunica... suspended                     livecomm                                              11516
    Microsoft.SkypeApp_2.8.0.1... suspended                     WWAHost                                               16796

.EXAMPLE
    PS C:\Users\Dave> Get-ProcessAppxPackage Skype
    
    PackageFullName               State                         ProcessName                                              Id
    ---------------               -----                         -----------                                              --
    Microsoft.SkypeApp_2.8.0.1... suspended                     WWAHost   

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
param([string] $ProcessFilter,
	[switch] $MergeType,
	[switch] $All);

$merge = !!$MergeType;

$myPath = Split-Path -Parent ($MyInvocation.MyCommand.Path);
function ScriptDir($additional) {
	$myPath + "\" + $additional;
}

$processAppxPackageType = "ProcessAppxPackageExtType";
if ((Get-TypeData $processAppxPackageType) -eq $null) { 
	Update-TypeData -TypeName $processAppxPackageType -DefaultDisplayPropertySet @("PackageFullName","State","ProcessName","Id");
}

$allInput = ($input | %{ $_; } | ?{ $_; });
if (!$allInput) {
	$allInput = (Get-Process);
}

$packageFullNameList = @();
$processIdToPackageFullName = @{};
$packageFullNameToExecutionState = @{};
$packageFullNameToPackage = @{};

$allInput.Id | .(ScriptDir("ProcessIdToPackageId.exe")) - | %{
	$split = $_.Split("`t");
	if ($split[1]) {
		$processIdToPackageFullName[[int]$split[0]] = $split[1];
		$packageFullNameList += $split[1];
	}
};

$packageFullNameList | .(ScriptDir("PackageExecutionState.exe")) /get - | %{
	$split = $_.Split("`t");
	if ($split[1]) {
		$packageFullNameToExecutionState[$split[0]] = $split[1];
	}
};

#(.(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge) | %{ 
Get-AppxPackage | %{
	$packageFullNameToPackage[$_.PackageFullName] = $_;
};

$allInput | %{
	$pfn = $processIdToPackageFullName[$_.Id];
	$package = $null;
	$packageState = $null;
	if ($pfn) {
		$package = $packageFullNameToPackage[$pfn];
		$packageState = $packageFullNameToExecutionState[$pfn];
	}

	$process = $_;
	$outputObject = $_;
	if (!$merge) {
		$outputObject = New-Object PSObject `
			| Add-Member Id $process.Id -PassThru `
			| Add-Member ProcessName $process.ProcessName -PassThru `
			| Add-Member Process $process -PassThru `
		;
		$outputObject.PSTypeNames.Add($processAppxPackageType);
	}

	$outputObject `
		| Add-Member PackageFullName $pfn -PassThru `
		| Add-Member Package $package -PassThru `
		| Add-Member State $packageState `
	;

	$filterMatch = $true;
	if ($ProcessFilter) {
		$filterMatch = ($outputObject.Id -eq $ProcessFilter) -or `
			($outputObject.ProcessName -like $ProcessFilter) -or `
			($outputObject.PackageFullName -like $ProcessFilter);
	}

	if (($ProcessFilter -and $filterMatch) -or (!$ProcessFilter -and ($All -or $pfn))) {
		$outputObject;
	}
}
