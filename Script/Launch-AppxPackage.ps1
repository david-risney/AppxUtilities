param([string] $PackageFamilyName,
	[string] $ApplicationId);

$myPath = ((Split-Path -Parent ($MyInvocation.MyCommand.Path));
$ApplicationUserModelId = $PackageFamilyName + "!" + $ApplicationId;

$input + $ApplicationUserModelId | %{
	$aumi = $_;
	if ($aumi.GetType().Name -ne "string") {
		$aumi = $_.PackageFamilyName + "!" + $_.ApplicationIds[0];
	}
	$launchAppxPackage = $myPath + "\LaunchAppxPackage.exe");
	$processId = (.$launchAppxPackage $aumi 2>&1);
	try {
		$processId = [int]$processId;
		ps $processId | .($myPath + "\Get-ProcessPackageFullName.ps1")
	}
	catch {
		throw $processId;
	}
};