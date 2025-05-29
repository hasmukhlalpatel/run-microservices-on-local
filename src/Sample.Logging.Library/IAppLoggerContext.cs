namespace Sample.Logging.Library
{
    public interface IAppLoggerContext
    {
        string CorrelationId { get; }
        string CorrelationIdSource { get; }
        string SourceMachine { get; }
        string UserId { get; }
        string XCorrelationId { get; }
        string GetContext();
    }
}