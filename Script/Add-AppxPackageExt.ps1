param([object[]] $Paths,
	[switch] $Force,
	[switch] $MergeType);

$PackagesAdded = @();

$merge = !!$MergeType;

$myPath = (Split-Path -Parent ($MyInvocation.MyCommand.Path));
function ScriptDir($additional) {
	 $myPath + "\" + $additional;
}

$Paths + $input | %{
	$Path = $_;
	if ($Path.GetType() -eq "FileInfo") {
		$Path = $Path.FullName;
	}

	$before = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;

	$lastError = (Add-AppxPackage $Path 2>&1);

    if ($lastError -and $Force) {
    	if ($error.CategoryInfo.Category -eq "ResourceExists") {
    		$errorPrefix = "Deployment of package ";
    		$lastError.Exception.Message.Split("`n") | ?{ $_ -match "Deployment of package" } | %{ $_ -replace "Deployment of package ([^ ]*).*","`$1" } | %{
    			Remove-AppxPackage $_
    			$before = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;
    			Add-AppxPackage $Path;
    		}
    	}
        elseif ($lastError.Exception -and `
            $lastError.Exception.InnerException -and `
            $lastError.Exception.InnerException.Message -eq "error 0x800B0109: The root certificate of the signature in the app package or bundle must be trusted.") {
    
            $certPath = $env:TEMP + "\Add-AppxPackageExt.tmp.cer";
            [System.IO.File]::WriteAllBytes($certPath, (Get-AuthenticodeSignature ($Path)).SignerCertificate.Export("Cert"));
            [void](certutil.exe -addstore TrustedPeople $certPath);
            Add-AppxPackage $Path;
            del $certPath;
        }
	    elseif ($lastError) {
		    $lastError;
	    }
    }
    else {
        $lastError;
    }

	$after = .(ScriptDir("Get-AppxPackageExt.ps1")) -MergeType:$merge;

	$before = @() + $before;
	$after = @() + $after;

	$PackagesAdded += @(diff $before $after | where SideIndicator -eq "=>" | %{ $_.InputObject })
}

$PackagesAdded;
