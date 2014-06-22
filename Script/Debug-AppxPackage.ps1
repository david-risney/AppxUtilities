param([object[]] $PackageFullNames,
	[string] $OnLaunch,
	[string] $On,
	[switch] $Off,
	[switch] $MergeType)

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

	.(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$MergeType | where PackageFullName -match $PackageFullName;
}
