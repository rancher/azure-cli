# Windows Azure Cli

Compile the azure cli for Windows Nanoserver.

## How to build azure cli

1. Setup a `1809` Windows server core
2. `git clone https://gihub.com/rancher/azure-cli`
3. `make.bat`
4. Expand `dist/azure-cli.zip` to Nanoserver
5. Append the exection `PATH`, e.g: if the expanded path is `c:\azure-cli`, update the environment variable `PATH` with `c:\azure-cli\python\;c:\azure-cli\python\Scripts\;$($env:PATH)`

## How to change azure cli version

Change the `AZURECLI_VERSION` from **Dockerfile.dapper** file.

## License

Copyright (c) 2014-2019 [Rancher Labs, Inc.](http://rancher.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
