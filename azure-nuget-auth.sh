#!/bin/bash
AZURE_URL_REGEX='(https:\/\/|)pkgs.dev.azure.com\/(.+)\/(.+)\/_packaging\/(.+)\/nuget'

# 
az_user_authenticated() {
    az account show &>/dev/null
}

# ask user for credentials if needed
az_user_authenticated
if [ $? -ne 0 ];
then
  az login
fi

# check if login succeeded
az_user_authenticated
if [ $? -ne 0 ];
then
  echo "Azure CLI authentication failed."
  exit 1
fi

# let user enter the URL for the nuget feed
echo "Enter the URL NuGet artifact source (example: https://pkgs.dev.azure.com/Fabrikam/Project/_packaging/NugetArtifactRepository/nuget/v3/index.json): "
read AZURE_NUGET_URL

# check if entered URL is valid
if [[ "$AZURE_NUGET_URL" =~ $AZURE_URL_REGEX ]];
then
  AZURE_GROUP="${BASH_REMATCH[2]}"
  AZURE_NUGET_REPOSITORY="${BASH_REMATCH[4]}"
else
  echo "Invalid NuGet URL provided!"
  exit 2
fi

echo "Azure Group: $AZURE_GROUP"
echo "NuGet Repository Name: $AZURE_NUGET_REPOSITORY"

# generate PAT
AZURE_TOKEN_RESULT=$(az rest --method post --uri "https://vssps.dev.azure.com/$AZURE_GROUP/_apis/Tokens/Pats?api-version=6.1-preview" --resource "https://management.core.windows.net/" --body '{ "displayName": "NuGet Token" }' --headers Content-Type=application/json)
AZURE_NUGET_TOKEN=$(echo "$AZURE_TOKEN_RESULT" | jq -r '.patToken.token')
if [ $? -ne 0 ];
then
  echo "Something went wrong while attempting to obtain PAT!"
  echo "API result: $AZURE_TOKEN_RESULT"
  exit 3
fi

# check if NuGet repository already exists
dotnet nuget list source | grep "$AZURE_NUGET_REPOSITORY" > /dev/null
if [ $? -eq 0 ];
then
  # NuGet repository already exists, update credentials
  echo "NuGet repository $AZURE_NUGET_REPOSITORY already exists, updating credentials..."
  dotnet nuget update source "$AZURE_NUGET_REPOSITORY" --store-password-in-clear-text --configfile "$HOME/.nuget/NuGet/NuGet.Config" --username "PAT" --password "$AZURE_NUGET_TOKEN"
else
  # NuGet repository does not yet exist, add repository
  echo "NuGet repository $AZURE_NUGET_REPOSITORY does not yet exist, adding NuGet repository!"
  dotnet nuget add source "$AZURE_NUGET_URL" --name "$AZURE_NUGET_REPOSITORY" --store-password-in-clear-text --configfile "$HOME/.nuget/NuGet/NuGet.Config" --username "PAT" --password "$AZURE_NUGET_TOKEN"
fi
