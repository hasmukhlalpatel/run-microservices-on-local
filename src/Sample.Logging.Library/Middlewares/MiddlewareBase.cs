using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
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
    }

}
