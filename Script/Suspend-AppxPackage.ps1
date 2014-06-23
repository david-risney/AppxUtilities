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
		.(ScriptDir("PackageExecutionState.exe")) /suspendAndWait $PackageFullName;
	}
	else {
		.(ScriptDir("PackageExecutionState.exe")) /suspend $PackageFullName;
	}

	.(ScriptDir("Get-ProcessAppxPackage.ps1")) $PackageFullName;
}
