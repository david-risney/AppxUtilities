param([string] $PackageFamilyName,
	[string] $ApplicationId);

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}


$ApplicationUserModelId = $PackageFamilyName + "!" + $ApplicationId;

$input + $ApplicationUserModelId | %{
	# Upgrade results from builtin Get-AppxPackage to results from AppxUtilities Get-AppxPackage.ps1
	if ($_.PackageFamilyName -and !$_.ApplicationIds) {
		$_ | .(ScriptDir("\Get-AppxPackageExt.ps1"))
	}
} | %{
	$aumi = $_;
	if ($aumi.GetType().Name -ne "string") {
		$aumi = $_.PackageFamilyName + "!" + $_.ApplicationIds[0];
	}
	$launchAppxPackage = $myPath + "\LaunchAppxPackage.exe";
	$processId = (.(ScriptDir("\LaunchAppxPackage.exe")) $aumi 2>&1);
	try {
		$processId = [int]$processId;
		.(ScriptDir("\pspfn.ps1")) $processId;
	}
	catch {
		throw $processId 
	}
};
