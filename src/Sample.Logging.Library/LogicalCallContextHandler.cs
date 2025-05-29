using Sample.Logging.Library.Extensions;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace Sample.Logging.Library
{
    //https://gist.github.com/hasmukhlalpatel/90930095f6d3d9dedffb7837a73929bd#file-logicalcallcontexthandler-cs
    public class LogicalCallContextHandler : DelegatingHandler
    {
        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            request.Headers.AddLogicalCallContextOnRequestHeaders();

            return await base.SendAsync(request, cancellationToken);
        }

        private static AppLoggerContext GetLoggerContext()
        {
            var loggerContext = LogicalCallContext<AppLoggerContext>.Current;
            return loggerContext;
        }
    }
}
