using System.Data;
using ShacabService.Models;

namespace ShacabService.Services;

public interface IUserRepository
{
    Task<IEnumerable<UserSummary>> GetAllUsersAsync(bool includeInactive = false, string? searchTerm = null, string? department = null, int? roleId = null);
    Task<UserDetails?> GetUserDetailsAsync(int userId);
    Task<UserDetails?> GetUserDetailsByUsernameAsync(string username);
    Task<int> CreateUserAsync(string username, string email, string passwordHash, string firstName, string lastName, string? department, string? roleIds);
    Task<UserSummary?> UpdateUserAsync(int userId, string? email, string? passwordHash, string? firstName, string? lastName, string? department, bool? isActive);
    Task<IEnumerable<UserRole>> ManageUserRolesAsync(int userId, string roleIds, string action);
}

public class UserRepository : IUserRepository
{
    private readonly IDatabaseService _db;

    public UserRepository(IDatabaseService db)
    {
        _db = db;
    }

    public async Task<IEnumerable<UserSummary>> GetAllUsersAsync(bool includeInactive = false, string? searchTerm = null, string? department = null, int? roleId = null)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@IncludeInactive", includeInactive },
            { "@SearchTerm", searchTerm },
            { "@Department", department },
            { "@RoleId", roleId }
        };

        return await _db.QueryAsync<UserSummary>(
            "GetAllUsers",
            parameters,
            reader => new UserSummary
            {
                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                Username = reader.GetString(reader.GetOrdinal("Username")),
                Email = reader.GetString(reader.GetOrdinal("Email")),
                FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                LastName = reader.GetString(reader.GetOrdinal("LastName")),
                Department = reader.IsDBNull(reader.GetOrdinal("Department")) ? null : reader.GetString(reader.GetOrdinal("Department")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                LastLoginDate = reader.IsDBNull(reader.GetOrdinal("LastLoginDate")) ? null : reader.GetDateTime(reader.GetOrdinal("LastLoginDate")),
                Roles = reader.IsDBNull(reader.GetOrdinal("Roles")) ? null : reader.GetString(reader.GetOrdinal("Roles"))
            });
    }

    public async Task<UserDetails?> GetUserDetailsAsync(int userId)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@UserId", userId },
            { "@Username", null }
        };

        return await GetUserDetailsInternalAsync(parameters);
    }

    public async Task<UserDetails?> GetUserDetailsByUsernameAsync(string username)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@UserId", null },
            { "@Username", username }
        };

        return await GetUserDetailsInternalAsync(parameters);
    }

    private async Task<UserDetails?> GetUserDetailsInternalAsync(Dictionary<string, object?> parameters)
    {
        var result = await _db.QueryMultipleAsync<UserDetails, UserRole, SupervisorRelationship, SupervisorRelationship, ChangeRequestSummary>(
            "GetUserDetails",
            parameters,
            // User details mapper
            reader => new UserDetails
            {
                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                Username = reader.GetString(reader.GetOrdinal("Username")),
                Email = reader.GetString(reader.GetOrdinal("Email")),
                FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                LastName = reader.GetString(reader.GetOrdinal("LastName")),
                Department = reader.IsDBNull(reader.GetOrdinal("Department")) ? null : reader.GetString(reader.GetOrdinal("Department")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                LastLoginDate = reader.IsDBNull(reader.GetOrdinal("LastLoginDate")) ? null : reader.GetDateTime(reader.GetOrdinal("LastLoginDate"))
            },
            // User roles mapper
            reader => new UserRole
            {
                RoleId = reader.GetInt32(reader.GetOrdinal("RoleId")),
                RoleName = reader.GetString(reader.GetOrdinal("RoleName")),
                RoleDescription = reader.GetString(reader.GetOrdinal("RoleDescription")),
                AssignedDate = reader.GetDateTime(reader.GetOrdinal("AssignedDate"))
            },
            // Supervisors mapper
            reader => new SupervisorRelationship
            {
                SupervisorId = reader.GetInt32(reader.GetOrdinal("SupervisorId")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                AssignedDate = reader.GetDateTime(reader.GetOrdinal("AssignedDate")),
                UserId = reader.GetInt32(reader.GetOrdinal("SupervisorUserId")),
                Name = reader.GetString(reader.GetOrdinal("SupervisorName")),
                Email = reader.GetString(reader.GetOrdinal("SupervisorEmail"))
            },
            // Supervisees mapper
            reader => new SupervisorRelationship
            {
                SupervisorId = reader.GetInt32(reader.GetOrdinal("SupervisorId")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                AssignedDate = reader.GetDateTime(reader.GetOrdinal("AssignedDate")),
                UserId = reader.GetInt32(reader.GetOrdinal("SuperviseeUserId")),
                Name = reader.GetString(reader.GetOrdinal("SuperviseeName")),
                Email = reader.GetString(reader.GetOrdinal("SuperviseeEmail"))
            },
            // Recent change requests mapper
            reader => new ChangeRequestSummary
            {
                ChangeRequestId = reader.GetInt32(reader.GetOrdinal("ChangeRequestId")),
                Title = reader.GetString(reader.GetOrdinal("Title")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                Priority = reader.GetString(reader.GetOrdinal("Priority")),
                SubmissionDate = reader.IsDBNull(reader.GetOrdinal("SubmissionDate")) ? null : reader.GetDateTime(reader.GetOrdinal("SubmissionDate")),
                LastModifiedDate = reader.GetDateTime(reader.GetOrdinal("LastModifiedDate")),
                // Minimal properties for recent change requests
                Description = string.Empty,
                ImpactLevel = string.Empty,
                RiskLevel = string.Empty,
                CreatedDate = DateTime.MinValue,
                RequesterId = 0,
                RequesterName = string.Empty
            });

        var userDetails = result.Item1.FirstOrDefault();
        if (userDetails == null)
            return null;

        userDetails.Roles = result.Item2.ToList();
        userDetails.Supervisors = result.Item3.ToList();
        userDetails.Supervisees = result.Item4.ToList();
        userDetails.RecentChangeRequests = result.Item5.ToList();

        return userDetails;
    }

    public async Task<int> CreateUserAsync(string username, string email, string passwordHash, string firstName, string lastName, string? department, string? roleIds)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@Username", username },
            { "@Email", email },
            { "@PasswordHash", passwordHash },
            { "@FirstName", firstName },
            { "@LastName", lastName },
            { "@Department", department },
            { "@RoleIds", roleIds },
            { "@UserIdOutput", null }
        };

        // Execute the stored procedure
        await _db.ExecuteNonQueryAsync("CreateUser", parameters);

        // Get the output parameter value
        using var connection = await _db.CreateConnectionAsync();
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT @UserIdOutput";
        command.Parameters.AddWithValue("@UserIdOutput", parameters["@UserIdOutput"]);
        var userId = (int)await command.ExecuteScalarAsync();

        return userId;
    }

    public async Task<UserSummary?> UpdateUserAsync(int userId, string? email, string? passwordHash, string? firstName, string? lastName, string? department, bool? isActive)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@UserId", userId },
            { "@Email", email },
            { "@PasswordHash", passwordHash },
            { "@FirstName", firstName },
            { "@LastName", lastName },
            { "@Department", department },
            { "@IsActive", isActive }
        };

        var result = await _db.QueryAsync<UserSummary>(
            "UpdateUser",
            parameters,
            reader => new UserSummary
            {
                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                Username = reader.GetString(reader.GetOrdinal("Username")),
                Email = reader.GetString(reader.GetOrdinal("Email")),
                FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                LastName = reader.GetString(reader.GetOrdinal("LastName")),
                Department = reader.IsDBNull(reader.GetOrdinal("Department")) ? null : reader.GetString(reader.GetOrdinal("Department")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                LastLoginDate = reader.IsDBNull(reader.GetOrdinal("LastLoginDate")) ? null : reader.GetDateTime(reader.GetOrdinal("LastLoginDate")),
                Roles = reader.IsDBNull(reader.GetOrdinal("Roles")) ? null : reader.GetString(reader.GetOrdinal("Roles"))
            });

        return result.FirstOrDefault();
    }

    public async Task<IEnumerable<UserRole>> ManageUserRolesAsync(int userId, string roleIds, string action)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@UserId", userId },
            { "@RoleIds", roleIds },
            { "@Action", action }
        };

        return await _db.QueryAsync<UserRole>(
            "ManageUserRoles",
            parameters,
            reader => new UserRole
            {
                RoleId = reader.GetInt32(reader.GetOrdinal("RoleId")),
                RoleName = reader.GetString(reader.GetOrdinal("RoleName")),
                RoleDescription = reader.GetString(reader.GetOrdinal("RoleDescription")),
                AssignedDate = reader.GetDateTime(reader.GetOrdinal("AssignedDate"))
            });
    }
} 