using System;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Samples.StorageQueue.Function
{
    public class SBQFunction
    {
        private readonly ILogger _logger;

        public SBQFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<SBQFunction>();
        }

        [Function("SBQFunction")]
        [BlobOutput("test-samples-output/{name}-output.txt")]
        public void Run([ServiceBusTrigger("mySBqueue", Connection = "MyServiceBus")] string myQueueItem)
        {
            _logger.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
        }
    }
}
