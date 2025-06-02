using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Sample.Logging.Library.Extensions;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace Sample.Logging.Library.Middlewares
{
    public abstract class MiddlewareBase
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<MiddlewareBase> _logger;

        protected MiddlewareBase(RequestDelegate next, ILogger<MiddlewareBase> logger)
        {
            _next = next;
            _logger = logger;
        }

        protected async Task<string> GetPayload(HttpContext context)
        {
            context.Request.EnableBuffering();
            string body = null;
            using (var reader = new StreamReader(context.Request.Body, Encoding.UTF8, leaveOpen: true))
            {
                body = await reader.ReadToEndAsync();
            }

            // Reset request body position for downstream processing
            context.Request.Body.Position = 0;
            return body;
        }
        protected virtual Task<IDictionary<string, string>> AddExtraMetadataAsync(HttpContext context)
        {
            return null;
        }

        protected virtual async Task ProcessExtraMetadataAsync(HttpContext context, IAppLoggerContext appLoggerContext)
        {
            var extraMetadata = await  AddExtraMetadataAsync(context);
            if (extraMetadata != null)
            {
                foreach (var metadata in extraMetadata)
                {
                    appLoggerContext.TryAddValue(metadata.Key, metadata.Value);
                }
            }
        }
        protected internal async Task InvokeInternalAsync(HttpContext context,
                Func<HttpContext, Task<(bool success, string correlationId, string correlationIdSource)>> GetCorrelationIdFromOtherSourceFunc = null)
        {
            var appLoggerContext = (AppLoggerContext)context.Request.Headers.BuildLogicalCallContext();
            // Generate or retrieve existing correlation id
            var correlationId = appLoggerContext.CorrelationId;
            var xCorrelationId = correlationId != null ? appLoggerContext.XCorrelationId : null;
            correlationId = correlationId ?? xCorrelationId;
            var correlationIdSource = correlationId == null ? "A New" : "In Header";

            if (correlationId == null && GetCorrelationIdFromOtherSourceFunc != null)
            {
                var fromOtherSourceResult = await GetCorrelationIdFromOtherSourceFunc(context);
                if (fromOtherSourceResult.success)
                {
                    correlationId = fromOtherSourceResult.correlationId;
                    correlationIdSource = fromOtherSourceResult.correlationIdSource;
                }
            }

            var loggerPropName = xCorrelationId != null && correlationId != null || xCorrelationId == null && correlationId == null
                ? Constants.XCorrelationId
                : Constants.CorrelationId;

            correlationId = correlationId ?? Guid.NewGuid().ToString();
            appLoggerContext.TryAddValue(loggerPropName, correlationId);
            appLoggerContext.TryAddValue(Constants.CorrelationIdSource, correlationIdSource);
            var clientIpAddress = context.Connection.RemoteIpAddress?.ToString();
            appLoggerContext.TryAddValue(Constants.SourceMachine, clientIpAddress);

            await ProcessExtraMetadataAsync(context, appLoggerContext);

            context.Features.Set<IAppLoggerContext>(appLoggerContext);

            using (new LogicalCallContext<IAppLoggerContext>(appLoggerContext))
            using (_logger.BeginScope(appLoggerContext))
            {
                _logger.LogInformation($"Start processing request with {loggerPropName}: {correlationId}, was {correlationIdSource}");
                await _next(context);
                _logger.LogInformation($"End processing request with [{loggerPropName}]: {correlationId}");

            }
        }
    }

}
