using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Samples.StorageQueue.Function
{
    public class StorageQueueFunction
    {
        private readonly ILogger _logger;

        public StorageQueueFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<StorageQueueFunction>();
        }

        [Function("StorageQueueFunctionSample")]
        public void Run([QueueTrigger("%Storage:QueueName%", Connection = "Storage:ConnectionString")] string myQueueItem)
        {
            _logger.LogInformation($"C# Queue trigger function processed: {myQueueItem}");
        }
    }
}
