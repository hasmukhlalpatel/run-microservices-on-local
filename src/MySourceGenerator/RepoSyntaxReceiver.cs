using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace MySourceGenerator;

/// <summary>
/// This will receive each "syntax context" to determine if we want to act
/// on it. Here, we'll capture a list of models that implement Entity.
/// </summary>
public class RepoSyntaxReceiver : ISyntaxContextReceiver
{
    public List<string> Models = new();

    public void OnVisitSyntaxNode(GeneratorSyntaxContext context)
    {
        if (context.Node is not ClassDeclarationSyntax classDec
            || classDec.BaseList == null)
        {
            return;
        }

        // If the base class list has Entity, we want to generate a repo for it!
        if (classDec.BaseList.Types.Any(t => t.ToString() == "Entity"))
        {
            Models.Add(classDec.Identifier.ToString());
        }
    }
}