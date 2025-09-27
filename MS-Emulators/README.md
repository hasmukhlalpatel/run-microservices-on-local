# Microsoft Emulators
# This directory contains information and resources related to Microsoft emulators that can be used for local development and testing of applications that integrate with Azure services.
## The emulators include:
	* Azure Cosmos DB Emulator
	* Azure Storage/azurite Emulator
	* Azure Service bus Emulator
	* Sel server Emulator

## Usage - How to Run
To use these emulators
```
docker-compose up

```

## PowerShell Script to manage emulators
A PowerShell script is provided to manage the lifecycle of these emulators. You can start, stop, and check the status of the emulators using the following commands:

### Function Wrapper (Best for parameters):

```
function emulators-setup { & "C:\Path\To\Your\Manage-Emulators.ps1" @args }
```

## Resources settings
* [Azure Cosmos DB Emulator](https://learn.microsoft.com/en-us/azure/cosmos-db/local-emulator?tabs=ssl-netstd21)
* [Azure Storage/ Azurite Emulator (Docker)](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=docker-hub%2Cblob-storage#run-azurite-in-a-docker-container)
* [Azure Service Bus Emulator](https://learn.microsoft.com/en-us/azure/service-bus-messaging/test-locally-with-service-bus-emulator?tabs=docker-linux-container)

## Quick Tips
### To connect to SQL Server, use:
```
Server=localhost,1433;User Id=sa;Password=YourStrong!Passw0rd;
```
### To connect to Azurite, use the default connection string:
```
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;
AccountKey=Eby8vdM02xNOcqFeq...;BlobEndpoint=http://localhost:10000/devstoreaccount1;
```
### To connect to Azure Cosmos DB Emulator, use:
```
AccountEndpoint=https://localhost:8081/;AccountKey=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==;
```
#### Usage Example (.NET SDK)
```csharp
CosmosClient client = new CosmosClient(
    "https://localhost:8081/",
    "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
);

```
### To connect to Azure Service Bus Emulator, use:
Connection String for Emulator
```
Endpoint=sb://localhost:9090/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=YourSharedAccessKey;

```
Or
```
Endpoint=sb://localhost:5672/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=localKey;UseDevelopmentEmulator=true;
```
