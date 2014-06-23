param([switch] $MergeType,
	[switch] $All);

begin {
	$myPath = Split-Path -Parent ($MyInvocation.MyCommand.Path);
	function ScriptDir($additional) {
		$myPath + "\" + $additional;
	}
}
process {
	$pfn = (.(ScriptDir("ProcessIdToPackageId.exe")) $_.Id).Split("`t")[1];
	$package = $null;
	$packageState = $null;
	if ($pfn) {
		$package = (.(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$MergeType) | ?{ $_.PackageFullName -match $pfn };
		$packageState = (.(ScriptDir("PackageExecutionState.exe")) /get $pfn);
	}

	$process = $_;
	$outputObject = $_;
	if (!$MergeType) {
		$outputObject = New-Object PSObject `
			| Add-Member Id $process.Id -PassThru `
			| Add-Member ProcessName $process.ProcessName -PassThru `
			| Add-Member Process $process -PassThru `
		;
	}

	$outputObject `
		| Add-Member PackageFullName $pfn -PassThru `
		| Add-Member Package $package -PassThru `
		| Add-Member State $packageState `
	;

	if ($All -or $package) {
		$outputObject;
	}
}
end {}
