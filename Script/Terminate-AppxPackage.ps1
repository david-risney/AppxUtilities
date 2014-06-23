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
