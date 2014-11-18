param(
    $InstallPath = "~\bin",
    $Force);

# Test if it already exists
if (Test-Path ($InstallPath + "\Launch-AppxPackage.ps1") -and !$Force) {
    throw "AppxUtilities already installed.";
}
else {
    # Make install directory
    if (!(Test-Path $InstallPath)) {
        mkdir $InstallPath;
    }
    $InstallPath = gi $InstallPath;

    # Update PATH to include install directory (if it doesn't already)
    $path = [Environment]::GetEnvironmentVariable("PATH", "User");
    $path = $path.Split(";");
    if (!($path | ?{ $_ -match $InstallPath.FullName })) {
        $path += @($InstallPath.FullName);
        $path = $path -join ";";
        [Environment]::SetEnvironmentVariable("PATH", $path, "User");
    }

    pushd $InstallPath;

    # Download zip into install directory
    $client = (New-Object Net.WebClient)
    $client.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    $client.DownloadFile("https://david-risney.github.io/AppxUtilities/AppxUtilities.zip", $InstallPath + "\AppxUtilities.zip")
    $zipFile = gi ($InstallPath + "\AppxUtilities.zip");

    # Extract zip to install directory
    [Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" ) | Out-Null;
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile.FullName, $InstallPath);

    # Delete zip
    rm AppxUtilities.zip;

    popd;
}
