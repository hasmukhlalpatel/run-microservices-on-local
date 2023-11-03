namespace RuntimeLib;

public abstract class RepositoryBase<T> : IRepository<T> where T : Entity
{
    public virtual async Task Add(T Entity)
    {
        await Task.CompletedTask;
        Console.WriteLine($"Added → {typeof(T).Name}");
    }

    public virtual async Task Delete(T Entity)
    {
        await Task.CompletedTask;
        Console.WriteLine($"Deleted → {typeof(T).Name}");
    }

    public virtual async Task Update(T Entity)
    {
        await Task.CompletedTask;
        Console.WriteLine($"Updated → {typeof(T).Name}");
    }
}