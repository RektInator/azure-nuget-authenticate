# Azure Nuget Authenticate
Simple script to authenticate yourself to your Azure Artifacts NuGet repositories on linux!

## Prerequisites
1. Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux)
2. .NET SDK (https://docs.microsoft.com/en-us/dotnet/core/install/linux)
3. jq (apt: ``sudo apt install jq -y``)

## Usage
Using cURL: ``bash <(curl -sL https://raw.githubusercontent.com/RektInator/azure-nuget-authenticate/main/azure-nuget-auth.sh)``

Using wget: ``bash <(wget -qO- https://raw.githubusercontent.com/RektInator/azure-nuget-authenticate/main/azure-nuget-auth.sh)``
