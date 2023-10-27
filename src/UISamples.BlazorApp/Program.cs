using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Azure.Messaging.ServiceBus.Administration;
using Microsoft.Extensions.Azure;
using UISamples.BlazorApp.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddSingleton<WeatherForecastService>();

var queueNames = await GetQueueNames()!;

var blobStorageUri = builder.Configuration["Storage:ServiceUri"]!;
var keyVaultUri = builder.Configuration["KeyVault:VaultUri"]!;
var serviceBusNamespace = builder.Configuration["ServiceBus:Namespace"];

builder.Services.AddAzureClients(clientBuilder =>
{
    // Register clients for each service
    clientBuilder.AddSecretClient(new Uri(keyVaultUri));
    clientBuilder.AddBlobServiceClient(new Uri(blobStorageUri))
        //.WithName("TestName")
        .ConfigureOptions(options =>
        {
            options.Retry.Mode = Azure.Core.RetryMode.Exponential;
            options.Retry.MaxRetries = 5;
            options.Retry.MaxDelay = TimeSpan.FromSeconds(120);
        }); 
    clientBuilder.AddServiceBusClientWithNamespace(
        $"{serviceBusNamespace}.servicebus.windows.net");
    clientBuilder.UseCredential(new DefaultAzureCredential());

    
    // Register a subclient for each Service Bus Queue
    foreach (string queue in queueNames)
    {
        clientBuilder.AddClient<ServiceBusSender, ServiceBusClientOptions>(
            (_, _, provider) => provider.GetService<ServiceBusClient>()
                .CreateSender(queue)).WithName(queue);
    }
    /*
      clientBuilder.AddBlobServiceClient(
            builder.Configuration.GetSection("PrivateStorage"))
        .WithName("PrivateStorage");
    //then 
        public HomeController(
        BlobServiceClient defaultClient,
        IAzureClientFactory<BlobServiceClient> clientFactory)
    {
        _publicStorage = defaultClient;
        _privateStorage = clientFactory.CreateClient("PrivateStorage");
    }
     */
});

/*
 builder.Services.AddAzureClients(clientBuilder =>
{
    clientBuilder.AddSecretClient(
        builder.Configuration.GetSection("KeyVault"));

    clientBuilder.AddBlobServiceClient(
        builder.Configuration.GetSection("Storage"));

    clientBuilder.AddServiceBusClientWithNamespace(
        builder.Configuration["ServiceBus:Namespace"]);

    clientBuilder.UseCredential(new DefaultAzureCredential());

    // Set up any default settings
    clientBuilder.ConfigureDefaults(
        builder.Configuration.GetSection("AzureDefaults"));
});
 */

/*
 * private readonly BlobServiceClient _blobServiceClient;
  
    public MyApiController(BlobServiceClient blobServiceClient)
    {
        _blobServiceClient = blobServiceClient;
    }
 */

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();


async Task<List<string>> GetQueueNames()
{
    // Query the available queues for the Service Bus namespace.
    var adminClient = new ServiceBusAdministrationClient
        ("<your_namespace>.servicebus.windows.net", new DefaultAzureCredential());
    var queueNames = new List<string>();

    // Because the result is async, the queue names need to be captured
    // to a standard list to avoid async calls when registering. Failure to
    // do so results in an error with the services collection.
    await foreach (QueueProperties queue in adminClient.GetQueuesAsync())
    {
        queueNames.Add(queue.Name);
    }

    return queueNames;
}