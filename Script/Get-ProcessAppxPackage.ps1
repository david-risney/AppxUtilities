param([switch] $MergeType);

begin {
	$myPath = Split-Path -Parent ($MyInvocation.MyCommand.Path);
	function ScriptDir($additional) {
		$myPath + "\" + $additional;
	}
}
process {
	$pfn = (.(ScriptDir("\ProcessIdToPackageId.exe")) $_.Id).Split("`t")[1];
	$process = $_;
	$outputObject = $_;
	if (!$MergeType) {
		$outputObject = New-Object PSObject `
			| Add-Member Id $process.Id `
			| Add-Member ProcessName $process.ProcessName `
			| Add-Member Process $process `
		;
	}

	$outputObject `
		| Add-Member PackageFullName $pfn `
		| Add-Member Package (.(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$MergeType $pfn) `
	;

	$outputObject;
}
end {}
