using Microsoft.Data.SqlClient;
using System.Data;

namespace ShacabService.Services;

public interface IDatabaseService
{
    Task<SqlConnection> CreateConnectionAsync();
    Task<T> ExecuteScalarAsync<T>(string procedureName, Dictionary<string, object?> parameters);
    Task<IEnumerable<T>> QueryAsync<T>(string procedureName, Dictionary<string, object?> parameters, Func<IDataReader, T> mapper);
    Task<(IEnumerable<T1>, IEnumerable<T2>)> QueryMultipleAsync<T1, T2>(string procedureName, Dictionary<string, object?> parameters, Func<IDataReader, T1> mapper1, Func<IDataReader, T2> mapper2);
    Task<(IEnumerable<T1>, IEnumerable<T2>, IEnumerable<T3>)> QueryMultipleAsync<T1, T2, T3>(string procedureName, Dictionary<string, object?> parameters, Func<IDataReader, T1> mapper1, Func<IDataReader, T2> mapper2, Func<IDataReader, T3> mapper3);
    Task<(IEnumerable<T1>, IEnumerable<T2>, IEnumerable<T3>, IEnumerable<T4>)> QueryMultipleAsync<T1, T2, T3, T4>(string procedureName, Dictionary<string, object?> parameters, Func<IDataReader, T1> mapper1, Func<IDataReader, T2> mapper2, Func<IDataReader, T3> mapper3, Func<IDataReader, T4> mapper4);
    Task<(IEnumerable<T1>, IEnumerable<T2>, IEnumerable<T3>, IEnumerable<T4>, IEnumerable<T5>)> QueryMultipleAsync<T1, T2, T3, T4, T5>(string procedureName, Dictionary<string, object?> parameters, Func<IDataReader, T1> mapper1, Func<IDataReader, T2> mapper2, Func<IDataReader, T3> mapper3, Func<IDataReader, T4> mapper4, Func<IDataReader, T5> mapper5);
    Task<int> ExecuteNonQueryAsync(string procedureName, Dictionary<string, object?> parameters);
}

public class DatabaseService : IDatabaseService
{
    private readonly string _connectionString;

    public DatabaseService(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<SqlConnection> CreateConnectionAsync()
    {
        var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();
        return connection;
    }

    public async Task<T> ExecuteScalarAsync<T>(string procedureName, Dictionary<string, object?> parameters)
    {
        using var connection = await CreateConnectionAsync();
        using var command = CreateCommand(connection, procedureName, parameters);
        var result = await command.ExecuteScalarAsync();
        return (T)Convert.ChangeType(result, typeof(T));
    }

    public async Task<IEnumerable<T>> QueryAsync<T>(string procedureName, Dictionary<string, object?> parameters, Func<IDataReader, T> mapper)
    {
        using var connection = await CreateConnectionAsync();
        using var command = CreateCommand(connection, procedureName, parameters);
        using var reader = await command.ExecuteReaderAsync();
        var results = new List<T>();
        
        while (await reader.ReadAsync())
        {
            results.Add(mapper(reader));
        }
        
        return results;
    }

    public async Task<(IEnumerable<T1>, IEnumerable<T2>)> QueryMultipleAsync<T1, T2>(
        string procedureName, 
        Dictionary<string, object?> parameters, 
        Func<IDataReader, T1> mapper1, 
        Func<IDataReader, T2> mapper2)
    {
        using var connection = await CreateConnectionAsync();
        using var command = CreateCommand(connection, procedureName, parameters);
        using var reader = await command.ExecuteReaderAsync();
        
        var results1 = new List<T1>();
        while (await reader.ReadAsync())
        {
            results1.Add(mapper1(reader));
        }
        
        await reader.NextResultAsync();
        var results2 = new List<T2>();
        while (await reader.ReadAsync())
        {
            results2.Add(mapper2(reader));
        }
        
        return (results1, results2);
    }

    public async Task<(IEnumerable<T1>, IEnumerable<T2>, IEnumerable<T3>)> QueryMultipleAsync<T1, T2, T3>(
        string procedureName, 
        Dictionary<string, object?> parameters, 
        Func<IDataReader, T1> mapper1, 
        Func<IDataReader, T2> mapper2, 
        Func<IDataReader, T3> mapper3)
    {
        using var connection = await CreateConnectionAsync();
        using var command = CreateCommand(connection, procedureName, parameters);
        using var reader = await command.ExecuteReaderAsync();
        
        var results1 = new List<T1>();
        while (await reader.ReadAsync())
        {
            results1.Add(mapper1(reader));
        }
        
        await reader.NextResultAsync();
        var results2 = new List<T2>();
        while (await reader.ReadAsync())
        {
            results2.Add(mapper2(reader));
        }
        
        await reader.NextResultAsync();
        var results3 = new List<T3>();
        while (await reader.ReadAsync())
        {
            results3.Add(mapper3(reader));
        }
        
        return (results1, results2, results3);
    }

    public async Task<(IEnumerable<T1>, IEnumerable<T2>, IEnumerable<T3>, IEnumerable<T4>)> QueryMultipleAsync<T1, T2, T3, T4>(
        string procedureName, 
        Dictionary<string, object?> parameters, 
        Func<IDataReader, T1> mapper1, 
        Func<IDataReader, T2> mapper2, 
        Func<IDataReader, T3> mapper3, 
        Func<IDataReader, T4> mapper4)
    {
        using var connection = await CreateConnectionAsync();
        using var command = CreateCommand(connection, procedureName, parameters);
        using var reader = await command.ExecuteReaderAsync();
        
        var results1 = new List<T1>();
        while (await reader.ReadAsync())
        {
            results1.Add(mapper1(reader));
        }
        
        await reader.NextResultAsync();
        var results2 = new List<T2>();
        while (await reader.ReadAsync())
        {
            results2.Add(mapper2(reader));
        }
        
        await reader.NextResultAsync();
        var results3 = new List<T3>();
        while (await reader.ReadAsync())
        {
            results3.Add(mapper3(reader));
        }
        
        await reader.NextResultAsync();
        var results4 = new List<T4>();
        while (await reader.ReadAsync())
        {
            results4.Add(mapper4(reader));
        }
        
        return (results1, results2, results3, results4);
    }

    public async Task<(IEnumerable<T1>, IEnumerable<T2>, IEnumerable<T3>, IEnumerable<T4>, IEnumerable<T5>)> QueryMultipleAsync<T1, T2, T3, T4, T5>(
        string procedureName, 
        Dictionary<string, object?> parameters, 
        Func<IDataReader, T1> mapper1, 
        Func<IDataReader, T2> mapper2, 
        Func<IDataReader, T3> mapper3, 
        Func<IDataReader, T4> mapper4, 
        Func<IDataReader, T5> mapper5)
    {
        using var connection = await CreateConnectionAsync();
        using var command = CreateCommand(connection, procedureName, parameters);
        using var reader = await command.ExecuteReaderAsync();
        
        var results1 = new List<T1>();
        while (await reader.ReadAsync())
        {
            results1.Add(mapper1(reader));
        }
        
        await reader.NextResultAsync();
        var results2 = new List<T2>();
        while (await reader.ReadAsync())
        {
            results2.Add(mapper2(reader));
        }
        
        await reader.NextResultAsync();
        var results3 = new List<T3>();
        while (await reader.ReadAsync())
        {
            results3.Add(mapper3(reader));
        }
        
        await reader.NextResultAsync();
        var results4 = new List<T4>();
        while (await reader.ReadAsync())
        {
            results4.Add(mapper4(reader));
        }
        
        await reader.NextResultAsync();
        var results5 = new List<T5>();
        while (await reader.ReadAsync())
        {
            results5.Add(mapper5(reader));
        }
        
        return (results1, results2, results3, results4, results5);
    }

    public async Task<int> ExecuteNonQueryAsync(string procedureName, Dictionary<string, object?> parameters)
    {
        using var connection = await CreateConnectionAsync();
        using var command = CreateCommand(connection, procedureName, parameters);
        return await command.ExecuteNonQueryAsync();
    }

    private SqlCommand CreateCommand(SqlConnection connection, string procedureName, Dictionary<string, object?> parameters)
    {
        var command = connection.CreateCommand();
        command.CommandText = procedureName;
        command.CommandType = CommandType.StoredProcedure;
        
        foreach (var parameter in parameters)
        {
            var sqlParameter = command.Parameters.AddWithValue(parameter.Key, parameter.Value ?? DBNull.Value);
            
            // Handle output parameters
            if (parameter.Key.StartsWith("@") && parameter.Key.EndsWith("Output"))
            {
                sqlParameter.Direction = ParameterDirection.Output;
            }
        }
        
        return command;
    }
} 