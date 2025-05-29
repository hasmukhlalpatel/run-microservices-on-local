using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace Sample.Logging.Library.Extensions
{
    public static class HttpHeadersExtensions
    {
        internal static void AddRequestHeader(this HttpHeaders headers, string key, string value)
        {

        }

        public static void AddLogicalCallContextOnRequestHeaders(this HttpHeaders headers)
        {
            try
            {
                var loggerContext = GetLoggerContext();
                if (loggerContext != null)
                {
                    headers.AddRequestHeader(Constants.CorrelationId, loggerContext.CorrelationId);
                    headers.AddRequestHeader(Constants.XCorrelationId, loggerContext.XCorrelationId);
                    var xContext = loggerContext.GetContext();
                    headers.AddRequestHeader(Constants.LogicalCallContext, xContext);
                }
            }
            catch (Exception)
            {
            }
        }

        private static IAppLoggerContext GetLoggerContext()
        {
            return LogicalCallContext<AppLoggerContext>.Current;
        }
        public static void AddLogicalCallContextOnRequestHeaders(this HttpClient httpclient)
        {
            httpclient.DefaultRequestHeaders.AddLogicalCallContextOnRequestHeaders();
        }

        public static string GetCorrelationId(this IHeaderDictionary headers)
        {
            return headers.TryGetValue(Constants.CorrelationId, out var value) ? value.FirstOrDefault() : null;
        }

        public static string GetXCorrelationId(this IHeaderDictionary headers)
        {
            return headers.TryGetValue(Constants.XCorrelationId, out var value) ? value.FirstOrDefault() : null;
        }
        public static string GetContext(this IHeaderDictionary headers)
        {
            return headers.TryGetValue(Constants.LogicalCallContext, out var value) ? value.FirstOrDefault() : null;
        }

        public static IAppLoggerContext BuildLogicalCallContext(this IHeaderDictionary headers)
        {
            var loggerContext = new AppLoggerContext();

            var correlationId = headers.GetCorrelationId();
            var xCorrelationId = correlationId == null ? headers.GetXCorrelationId() : null;
            loggerContext.TryAddValue(Constants.CorrelationId, correlationId);
            loggerContext.TryAddValue(Constants.XCorrelationId, xCorrelationId);

            var xContext = headers.GetContext();
            if (!string.IsNullOrEmpty(xContext))
            {
                foreach (var item in xContext.Split('|'))
                {
                    var keyValueArr = item.Split("=");
                    if (keyValueArr.Length != 2) { continue; }
                    loggerContext.TryAddValue(keyValueArr.First(), keyValueArr.Last());
                }
            }

            return loggerContext;
        }
    }
}
