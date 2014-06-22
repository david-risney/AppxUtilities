begin {
	$myPath = Split-Path -Parent ($MyInvocation.MyCommand.Path);
	function ScriptDir($additional) {
		$myPath + "\" + $additional;
	}
}
process {
	$pfn = (.(ScriptDir("\ProcessIdToPackageId.exe")) $_.Id).Split("`t")[1];
	$_ | Add-Member PackageFullName $pfn;

	$_;
}
end {}
