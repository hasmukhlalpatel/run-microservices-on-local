using Microsoft.Azure.Functions.Worker.Middleware;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults(app =>
    {
        app.UseMiddleware<MyHttpHeaderMiddleware>();
        
    })
    .ConfigureServices(s =>
    {

    })
    .Build();

host.Run();


class MyHttpHeaderMiddleware : IFunctionsWorkerMiddleware
{
    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        await next(context);

        //var requestData = await context.GetHttpRequestDataAsync();

        //string correlationId;
        //if (requestData!.Headers.TryGetValues("x-correlationId", out var values))
        //{
        //    correlationId = values.First();
        //}
        //else
        //{
        //    correlationId = Guid.NewGuid().ToString();
        //}

        //await next(context);

        //context.GetHttpResponseData()?.Headers.Add("x-correlationId", correlationId);
    }
}