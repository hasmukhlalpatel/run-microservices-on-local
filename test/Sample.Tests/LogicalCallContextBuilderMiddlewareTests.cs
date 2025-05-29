using Sample.Logging.Library;
using Microsoft.AspNetCore.Http;
using Moq;
using Sample.Logging.Library.Middlewares;
using Microsoft.Extensions.Logging;
using FluentAssertions;

namespace Sample.Tests
{
    //https://gist.github.com/hasmukhlalpatel/90930095f6d3d9dedffb7837a73929bd#file-logicalcallcontextbuildermiddlewaretests-cs
    public class LogicalCallContextBuilderMiddlewareTests
    {
            LogicalCallContextBuilderMiddleware middleware;

            RequestDelegate requestDelegate = async (ctx) => {
                await ctx.Response.WriteAsync("Test");
                await Task.CompletedTask;
            };

            Mock<ILogger<LogicalCallContextBuilderMiddleware>> mockLogger;

            public LogicalCallContextBuilderMiddlewareTests()
            {
                mockLogger = new Mock<ILogger<LogicalCallContextBuilderMiddleware>>();
                middleware = new LogicalCallContextBuilderMiddleware(requestDelegate, mockLogger.Object);
            }

            [Fact]
            public async Task ProcessRequestAndExtractCorrelationIdFromHeader()
            {
                var correlationId = Guid.NewGuid().ToString();
                var context = new DefaultHttpContext();
                context.Request.Headers.TryAdd(LoggingConstants.CorrelationId, correlationId);
                using (context.Response.Body = new MemoryStream())
                {
                    await middleware.Invoke(context);
                    context.Response.Body.Seek(0, SeekOrigin.Begin);
                    var body = new StreamReader(context.Response.Body).ReadToEnd();
                    body.Should().Be("Test");
                }

                var appLoggerContext = context.Features.Get<AppLoggerContext>();
                appLoggerContext.Should().NotBeNull();
                appLoggerContext.CorrelationId.Should().Be(correlationId);
            }

            [Fact]
            public async Task ProcessRequestAndExtractCorrelationIdFromPayload()
            {
                var correlationId = Guid.NewGuid().ToString();
                var context = new DefaultHttpContext();
                using (var requestStream = new MemoryStream())
                using (context.Response.Body = new MemoryStream())
                {
                    var writer = new StreamWriter(requestStream);
                    writer.Write("{\"CorrelationId\":\"" + correlationId + "\"}");
                    writer.Flush();
                    requestStream.Position = 0;

                    context.Request.Body = requestStream;
                    await middleware.Invoke(context);
                    context.Response.Body.Seek(0, SeekOrigin.Begin);
                    var body = new StreamReader(context.Response.Body).ReadToEnd();
                    body.Should().Be("Test");

                    var appLoggerContext = context.Features.Get<AppLoggerContext>();
                    appLoggerContext.Should().NotBeNull();
                    appLoggerContext.CorrelationId.Should().Be(correlationId);
                }
            }
        }
}
