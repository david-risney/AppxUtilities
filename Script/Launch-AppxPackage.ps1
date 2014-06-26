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
