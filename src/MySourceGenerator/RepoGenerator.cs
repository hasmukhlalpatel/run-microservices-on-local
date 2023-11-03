using Microsoft.CodeAnalysis;

namespace MySourceGenerator;

/// <summary>
/// This is our generator that actually outputs the source code.
/// </summary>
[Generator]
public class RepoGenerator : ISourceGenerator
{
    /// <summary>
    /// We hook up our receiver here so that we can access it later.
    /// </summary>
    public void Initialize(GeneratorInitializationContext context)
    {
        context.RegisterForSyntaxNotifications(() => new RepoSyntaxReceiver());
    }

    /// <summary>
    /// And consume the receiver here.
    /// </summary>
    public void Execute(GeneratorExecutionContext context)
    {
        var models = (context.SyntaxContextReceiver as RepoSyntaxReceiver).Models;

        foreach (var modelClass in models)
        {
            var src = $@"
using System;

namespace runtime;

public partial class {modelClass}Repository : RepositoryBase<{modelClass}> {{ }}";

            context.AddSource($"{modelClass}Repository.g.cs", src);
        }
    }
}