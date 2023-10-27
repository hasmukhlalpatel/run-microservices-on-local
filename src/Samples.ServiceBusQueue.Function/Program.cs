using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Middleware;
using Microsoft.Extensions.Hosting;

//https://learn.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide
var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults(app =>
    {
        app.UseMiddleware<MyMiddleware>();
        
    })
    .Build();

host.Run();

//TODO: add health check and monitoring


class MyMiddleware : IFunctionsWorkerMiddleware
{
    public Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        return next(context);
    }
}
