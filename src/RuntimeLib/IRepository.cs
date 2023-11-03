namespace RuntimeLib;

public interface IRepository<T> where T : Entity
{
    Task Add(T Entity);
    Task Delete(T Entity);
    Task Update(T Entity);
}