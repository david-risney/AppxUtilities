param(
    $InstallPath = "~\bin",
    $Force);

# Make install directory
if (!(Test-Path $InstallPath)) {
    "Creating install path: "  + $InstallPath;
    mkdir $InstallPath;
}
else {
    "Install path already exists: "  + $InstallPath;
}
$InstallPath = gi $InstallPath;

# Update PATH to include install directory (if it doesn't already)
$path = [Environment]::GetEnvironmentVariable("PATH", "User");
if (!$path) {
    $path = "";
}
$path = $path.Split(";");
if (!($path | ?{ $_ -eq $InstallPath.FullName })) {
    $path += @($InstallPath.FullName);
    $path = $path -join ";";
    [Environment]::SetEnvironmentVariable("PATH", $path, "User");
    "PATH env variable updated to include install path."
}
else {
    "PATH env variable already contains install path."
}

pushd $InstallPath;

# Download zip into install directory
$client = (New-Object Net.WebClient);
$client.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials;
$client.DownloadFile("https://david-risney.github.io/AppxUtilities/AppxUtilities.zip", $InstallPath.FullName + "\AppxUtilities.zip");
$zipFile = gi ($InstallPath.FullName + "\AppxUtilities.zip");

# Extract zip to install directory
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null;
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile.FullName, $InstallPath.FullName);

# Delete zip
rm AppxUtilities.zip;

popd;
