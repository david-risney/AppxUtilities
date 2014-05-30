begin {
	$defaultDisplaySet = "Handles", "NPM", "PM", "WS", "VM", "CPU", "Id", "ProcessName", "PackageFamilyName";
	$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet", [string[]] $defaultDisplaySet)
	$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet);
}
process {
	$pfn = (ProcessIdToPackageId $_.Id).Split("`t")[1];
	$_ | Add-Member PackageFamilyName $pfn;

	$_.PSObject.TypeNames.Insert(0, "ProcessWithPackageFamilyName");
    # $_ | Add-Member -Force MemberSet PSStandardMembers $PSStandardMembers;

	$_;
}
end {}