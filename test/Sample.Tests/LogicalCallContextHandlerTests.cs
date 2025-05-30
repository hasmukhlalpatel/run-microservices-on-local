using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Moq;
using Sample.Logging.Library;
using Sample.Logging.Library.Middlewares;

namespace Sample.Tests
{
    public class LogicalCallContextHandlerTests
    {
        private LogicalCallContextBuilderMiddleware middleware;
        private RequestDelegate next = async (ctx) =>
        {
            await ctx.Response.WriteAsync("Test");
            await Task.CompletedTask;
        };

        private Mock<ILogger<LogicalCallContextBuilderMiddleware>> mockLogger;

        public LogicalCallContextHandlerTests()
        {
            mockLogger = new Mock<ILogger<LogicalCallContextBuilderMiddleware>>();
            middleware = new LogicalCallContextBuilderMiddleware(next, mockLogger.Object);
        }

        [Test]
        public async Task AddLogicalCallContextIntoHttpClient()
        {
            var requestMessage = new HttpRequestMessage(HttpMethod.Get, "http://localhost");

            middleware = new LogicalCallContextBuilderMiddleware(async (ctx) =>
            {
                using (var logicalCallContextHandler = new LogicalCallContextHandler(new TestHttpMessageHandler()))
                {
                    var httpClient = new HttpClient(logicalCallContextHandler);
                    var responseMessage = await httpClient.SendAsync(requestMessage);
                    await ctx.Response.WriteAsync("Test");
                }
            }, mockLogger.Object);

            var correlationId = Guid.NewGuid().ToString();
            var context = new DefaultHttpContext();
            context.Connection.RemoteIpAddress = new System.Net.IPAddress(new byte[] { 1, 1, 1, 1 });
            context.Request.Headers.TryAdd(LoggingConstants.CorrelationId, correlationId);
            using (context.Response.Body = new MemoryStream())
            {
                await middleware.Invoke(context);
            }

            requestMessage.Headers.Should().NotBeNull();
            requestMessage.Headers.GetValues(LoggingConstants.CorrelationId).First().Should().Be(correlationId);
            requestMessage.Headers.GetValues(LoggingConstants.LogicalCallContext).First().Should().NotBeNullOrEmpty();
        }

        class TestHttpMessageHandler : HttpMessageHandler
        {
            protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancell
            {
                return new HttpResponseMessage(System.Net.HttpStatusCode.OK);
            }
        }
    }
}
