param([int] $Id, [alias("Pfn")] [string] $PackageFamilyName);


if ($Id -gt 0) { 
	ps $Id | .\Add-PackageFamilyName.ps1;
} else { 
	ps | .\Add-PackageFamilyName.ps1 | where PackageFamilyName -match $PackageFamilyName;
}