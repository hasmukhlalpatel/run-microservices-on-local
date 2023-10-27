using System;
using System.Collections.Generic;
using System.Threading;

namespace Samples.Shared
{
    public class AILoggerContext
    {
        public string CorrelationId { get; set; }

    }
    public class LogicalCallContext<T> : IDisposable where T : class, new()
    {
        private static readonly AsyncLocal<Stack<T>> _asyncLocal = new AsyncLocal<Stack<T>>();

        public LogicalCallContext(T t)
        {
            AsyncLocal<Stack<T>> asyncLocal = LogicalCallContext<T>._asyncLocal;
            if (asyncLocal.Value == null)
            {
                Stack<T> objStack;
                asyncLocal.Value = objStack = new Stack<T>();
            }
            LogicalCallContext<T>._asyncLocal.Value.Push(t);
        }

        public static T Current
        {
            get
            {
                Stack<T> objStack = LogicalCallContext<T>._asyncLocal.Value;
                return objStack == null || objStack.Count <= 0 ? new T() : objStack.Peek();
            }
        }

        public static IReadOnlyCollection<T> ContextValues => (IReadOnlyCollection<T>)LogicalCallContext<T>._asyncLocal.Value ?? (IReadOnlyCollection<T>)new Stack<T>();

        public void Dispose()
        {
            LogicalCallContext<T>._asyncLocal.Value?.Pop();
            GC.SuppressFinalize((object)this);
        }
    }
}
