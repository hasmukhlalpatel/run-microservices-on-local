using System;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Samples.ServiceBusQueue.Function
{
    public class ServiceBusQueueFunction
    {
        private readonly ILogger _logger;

        public ServiceBusQueueFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<ServiceBusQueueFunction>();
        }

        [Function("ServiceBusQueueFunctionSample")]
        public void Run([ServiceBusTrigger("myqueue", Connection = "EmulatorConnectionString")] string myQueueItem)
        {
            _logger.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
        }
    }
}
