$ErrorActionPreference = 'Stop'

Import-Module -WarningAction Ignore -Name "$PSScriptRoot\utils.psm1"

Log-Info "Running: build azure-cli"
Remove-Item -Force -Path c:\dist\azure-cli.zip -ErrorAction Ignore

# download azure-cli #
pushd c:\
$URL = ('https://github.com/Azure/azure-cli/archive/azure-cli-{0}.zip' -f $env:AZURECLI_VERSION)
Log-Info ('Downloading azure-cli from {0} ...'  -f $URL)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -UseBasicParsing -OutFile c:\azure-cli.zip -Uri $URL
Log-Info 'Expanding ...'
Expand-Archive -Force -Path c:\azure-cli.zip -DestinationPath c:\
Move-Item -Force -Path ('c:\azure-cli-azure-cli-{0}' -f $env:AZURECLI_VERSION) -Destination c:\azure-cli-srcs
Log-Info 'Complete.'
popd

# build azure-cli #
pushd c:\azure-cli-srcs
Log-Info 'Building azure-cli...'
pip install wheel
Log-Info 'Building python packages...'
$wheels = Join-Path $pwd 'wheels'
$folder = @('src\azure-cli')
foreach($f in $folder) {
    try {
        pushd $f
        python setup.py bdist_wheel -d $wheels
    }
    finally {
        popd;
    }
}
Log-Info 'Installing python packages...'
pushd $wheels
$modules = (Get-ChildItem *.whl -Name)
foreach($m in $modules) {
    pip install --no-cache-dir $m
}
pip install --no-cache-dir --force-reinstall --upgrade azure-nspkg azure-mgmt-nspkg
popd
Log-Info 'Complete.'
popd

# compress azure-cli #
pushd c:\
Log-Info 'Compressing azure-cli...'
New-Item -ItemType "directory" -Path c:\azure-cli\dist -Force -ErrorAction Ignore | Out-Null
Compress-Archive -Path c:\python -DestinationPath c:\azure-cli\dist\azure-cli.zip
Log-Info 'Complete.'
popd
