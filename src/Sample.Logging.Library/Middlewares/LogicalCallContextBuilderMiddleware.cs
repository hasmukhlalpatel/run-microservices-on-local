using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Sample.Logging.Library.Extensions;
using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Sample.Logging.Library.Middlewares
{
    //https://gist.github.com/hasmukhlalpatel/90930095f6d3d9dedffb7837a73929bd#file-logicalcallcontextbuildermiddleware-cs
    public class LogicalCallContextBuilderMiddleware : MiddlewareBase
    {
        private readonly RequestDelegate _next;
        private readonly ILogger _logger;

        public LogicalCallContextBuilderMiddleware(RequestDelegate next,
            ILogger<LogicalCallContextBuilderMiddleware> logger) : base(next, logger)
        {
            _next = next;
            _logger = logger;
        }

        static Regex regex = new Regex("\"(?:correlationId|CorrelationId)\"\\s*:\\s*\"([^\"]+)\"", RegexOptions.IgnoreCase);

        public async Task Invoke(HttpContext context)
        {
            var appLoggerContext = (AppLoggerContext)context.Request.Headers.BuildLogicalCallContext();

            // Generate or retrieve existing correlation ID
            var correlationId = appLoggerContext.CorrelationId;
            var xCorrelationId = correlationId == null ? appLoggerContext.XCorrelationId : null;
            correlationId = correlationId ?? xCorrelationId;
            var correlationIdSource = correlationId == null ? "a New" : "in Header";

            if (correlationId == null)
            {
                _logger.LogWarning("Trying to get CorrelationId from Payload/Body.");

                var body = await GetPayload(context);
                if (!string.IsNullOrWhiteSpace(body))
                {
                    var match = regex.Match(body);
                    if (match.Success)
                    {
                        correlationId = match.Groups[1].Value;
                        correlationIdSource = "in Payload";
                    }
                }
            }

            var loggerPropName = xCorrelationId != null && correlationId == null || xCorrelationId == null && correlationId == null
                ? Constants.XCorrelationId
                : Constants.CorrelationId;

            correlationId = correlationId ?? Guid.NewGuid().ToString();
            appLoggerContext.TryAddValue(loggerPropName, correlationId);
            appLoggerContext.TryAddValue(Constants.CorrelationIdSource, correlationIdSource);

            context.Features.Set(appLoggerContext);

            using (new LogicalCallContext<AppLoggerContext>(appLoggerContext))
            using (_logger.BeginScope(appLoggerContext))
            {
                _logger.LogInformation($"Start processing request with [{loggerPropName}]: {correlationId}, was [{correlationIdSource}]");
                await _next(context);
                _logger.LogInformation($"End processing request with [{loggerPropName}]: {correlationId}");
            }
        }
    }

}
