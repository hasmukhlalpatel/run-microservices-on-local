using System.Collections.Generic;

namespace Sample.Logging.Library
{
    public interface IAppLoggerContext: IDictionary<string, object>
    {
        string CorrelationId { get; }
        string CorrelationIdSource { get; }
        string SourceMachine { get; }
        string UserId { get; }
        string XCorrelationId { get; }
        string GetContext();
        bool TryAddValue(string key, string value);
    }
}