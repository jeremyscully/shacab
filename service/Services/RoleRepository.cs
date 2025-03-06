using System.Data;
using ShacabService.Models;

namespace ShacabService.Services;

public interface IRoleRepository
{
    Task<IEnumerable<RoleInfo>> GetAllRolesAsync();
    Task<RoleInfo?> GetRoleAsync(int roleId);
    Task<int> CreateRoleAsync(string name, string description);
}

public class RoleRepository : IRoleRepository
{
    private readonly IDatabaseService _db;

    public RoleRepository(IDatabaseService db)
    {
        _db = db;
    }

    public async Task<IEnumerable<RoleInfo>> GetAllRolesAsync()
    {
        // This is a simple query that doesn't need a stored procedure
        using var connection = await _db.CreateConnectionAsync();
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT RoleId, Name, Description FROM Roles ORDER BY Name";
        command.CommandType = CommandType.Text;
        
        using var reader = await command.ExecuteReaderAsync();
        var roles = new List<RoleInfo>();
        
        while (await reader.ReadAsync())
        {
            roles.Add(new RoleInfo
            {
                RoleId = reader.GetInt32(reader.GetOrdinal("RoleId")),
                Name = reader.GetString(reader.GetOrdinal("Name")),
                Description = reader.GetString(reader.GetOrdinal("Description"))
            });
        }
        
        return roles;
    }

    public async Task<RoleInfo?> GetRoleAsync(int roleId)
    {
        // This is a simple query that doesn't need a stored procedure
        using var connection = await _db.CreateConnectionAsync();
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT RoleId, Name, Description FROM Roles WHERE RoleId = @RoleId";
        command.CommandType = CommandType.Text;
        command.Parameters.AddWithValue("@RoleId", roleId);
        
        using var reader = await command.ExecuteReaderAsync();
        
        if (await reader.ReadAsync())
        {
            return new RoleInfo
            {
                RoleId = reader.GetInt32(reader.GetOrdinal("RoleId")),
                Name = reader.GetString(reader.GetOrdinal("Name")),
                Description = reader.GetString(reader.GetOrdinal("Description"))
            };
        }
        
        return null;
    }

    public async Task<int> CreateRoleAsync(string name, string description)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@Name", name },
            { "@Description", description },
            { "@RoleIdOutput", null }
        };

        // Execute the stored procedure
        await _db.ExecuteNonQueryAsync("CreateRole", parameters);

        // Get the output parameter value
        using var connection = await _db.CreateConnectionAsync();
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT @RoleIdOutput";
        command.Parameters.AddWithValue("@RoleIdOutput", parameters["@RoleIdOutput"]);
        var roleId = (int)await command.ExecuteScalarAsync();

        return roleId;
    }
} 