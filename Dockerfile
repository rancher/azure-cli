ARG SERVERCORE_VERSION

FROM mcr.microsoft.com/windows/servercore:${SERVERCORE_VERSION} as builder
SHELL ["powershell", "-NoLogo", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
# download python
ENV PYTHON_VERSION=3.6.5
RUN $URL = ('https://www.python.org/ftp/python/{0}/python-{0}-amd64.exe' -f $env:PYTHON_VERSION); \
    \
    Write-Host ('Downloading python from {0} ...'  -f $URL); \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -UseBasicParsing -OutFile c:\python-installer.exe -Uri $URL; \
    \
    Write-Host 'Installing ...'; \
    Start-Process c:\python-installer.exe -NoNewWindow -Wait -ArgumentList '/quiet InstallAllUsers=1 TargetDir=c:\python PrependPath=1 Shortcuts=0 Include_doc=0 Include_pip=0 Include_test=0'; \
    \
    Write-Host 'Refresh local PATH ...'; \
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::Machine); \
    \
    Write-Host 'Verifying install ...'; \
    Write-Host '  python --version'; python --version; \
    \
    Write-Host 'Complete.'
# download pip
ENV PYTHON_PIP_VERSION=19.1.1
RUN $URL = 'https://bootstrap.pypa.io/get-pip.py'; \
    \
    Write-Host ('Downloading get-pip from {0} ...'  -f $URL); \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -UseBasicParsing -OutFile c:\get-pip.py -Uri $URL; \
    \
    Write-Host 'Installing pip ...'; \
    python c:\get-pip.py --disable-pip-version-check --no-cache-dir ('pip=={0}' -f $env:PYTHON_PIP_VERSION); \
    \
    Write-Host 'Verifying install ...'; \
    Write-Host '  pip --version'; pip --version; \
    \
    Write-Host 'Complete.'
# download azure-cli sources
ENV AZURECLI_VERSION=2.0.69
RUN $URL = ('https://github.com/Azure/azure-cli/archive/azure-cli-{0}.zip' -f $env:AZURECLI_VERSION); \
    \
    Write-Host ('Downloading azure-cli from {0} ...'  -f $URL); \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -UseBasicParsing -OutFile c:\azure-cli.zip -Uri $URL; \
    \
    Write-Host 'Expanding ...'; \
    Expand-Archive -Force -Path c:\azure-cli.zip -DestinationPath c:\; \
    Move-Item -Force -Path ('c:\azure-cli-azure-cli-{0}' -f $env:AZURECLI_VERSION) -Destination c:\azure-cli; \
    \
    Write-Host 'Complete.'
# build azure-cli
RUN pushd c:\azure-cli; \
    Write-Host 'Building azure-cli...'; \
    pip install wheel; \
    \
    Write-Host 'Building python packages...'; \
    $wheels = Join-Path $pwd 'wheels'; \
    $folder = @('src\azure-cli'); \
    foreach($f in $folder) { \
        try { \
            pushd $f; \
            python setup.py bdist_wheel -d $wheels; \
        } \
        finally { \
            popd; \
        } \
    } \
    \
    Write-Host 'Installing python packages...'; \
    pushd $wheels; \
    $modules = (Get-ChildItem *.whl -Name); \
    foreach($m in $modules) { \
        pip install --no-cache-dir $m; \
    } \
    pip install --no-cache-dir --force-reinstall --upgrade azure-nspkg azure-mgmt-nspkg; \
    popd; \
    \
    Write-Host 'Complete.'; \
    popd

FROM mcr.microsoft.com/powershell:nanoserver-${SERVERCORE_VERSION}
COPY --from=builder /python /azure-cli
