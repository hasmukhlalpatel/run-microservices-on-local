using System.Collections.Generic;

namespace Sample.Logging.Library
{
    public class AppLoggerContext : Dictionary<string, string>, IAppLoggerContext
    {
        public AppLoggerContext() { }
        public AppLoggerContext(Dictionary<string, string> dictionary)
            : base(dictionary)
        {
        }

        public string CorrelationId => TryGetValue(Constants.CorrelationId);

        public string XCorrelationId => TryGetValue(Constants.XCorrelationId);

        public string CorrelationIdSource => TryGetValue(Constants.CorrelationIdSource);

        public string SourceMachine => TryGetValue(Constants.SourceMachine);

        public string UserId => TryGetValue(Constants.UserId);

        protected string TryGetValue(string key)
        {
            return TryGetValue(key, out var value) ? value : null;
        }

        string IAppLoggerContext.GetContext()
        {
            var xContext = new List<string>();
            foreach (var key in Keys)
            {
                xContext.Add($"{key}={this[key]}");
            }
            return string.Join("|", xContext);
        }

        internal bool TryAddValue(string key, string value)
        {
            if (string.IsNullOrEmpty(key) || string.IsNullOrEmpty(value))
                return false;
            return this.TryAdd(key, value);
        }
    }
}
