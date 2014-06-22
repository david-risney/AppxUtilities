begin {}
process {
	$processIdToPackageId = ((Split-Path -Parent ($MyInvocation.MyCommand.Path)) + "\ProcessIdToPackageId.exe");
	$pfn = (.$processIdToPackageId $_.Id).Split("`t")[1];
	$_ | Add-Member PackageFullName $pfn;

	$_;
}
end {}