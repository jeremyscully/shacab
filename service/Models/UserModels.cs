namespace ShacabService.Models;

// Request models
public class CreateUserRequest
{
    public required string Username { get; set; }
    public required string Email { get; set; }
    public required string PasswordHash { get; set; }
    public required string FirstName { get; set; }
    public required string LastName { get; set; }
    public string? Department { get; set; }
    public string? RoleIds { get; set; }
}

public class UpdateUserRequest
{
    public string? Email { get; set; }
    public string? PasswordHash { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Department { get; set; }
    public bool? IsActive { get; set; }
}

public class ManageUserRolesRequest
{
    public required string RoleIds { get; set; }
    public required string Action { get; set; } // Add, Remove, or Set
}

// Response models
public class UserSummary
{
    public int UserId { get; set; }
    public required string Username { get; set; }
    public required string Email { get; set; }
    public required string FirstName { get; set; }
    public required string LastName { get; set; }
    public string FullName => $"{FirstName} {LastName}";
    public string? Department { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime? LastLoginDate { get; set; }
    public string? Roles { get; set; }
}

public class UserDetails
{
    public int UserId { get; set; }
    public required string Username { get; set; }
    public required string Email { get; set; }
    public required string FirstName { get; set; }
    public required string LastName { get; set; }
    public string FullName => $"{FirstName} {LastName}";
    public string? Department { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime? LastLoginDate { get; set; }
    public List<UserRole> Roles { get; set; } = new();
    public List<SupervisorRelationship> Supervisors { get; set; } = new();
    public List<SupervisorRelationship> Supervisees { get; set; } = new();
    public List<ChangeRequestSummary> RecentChangeRequests { get; set; } = new();
}

public class UserRole
{
    public int RoleId { get; set; }
    public required string RoleName { get; set; }
    public required string RoleDescription { get; set; }
    public DateTime AssignedDate { get; set; }
}

public class SupervisorRelationship
{
    public int SupervisorId { get; set; }
    public required string Department { get; set; }
    public DateTime AssignedDate { get; set; }
    public int UserId { get; set; }
    public required string Name { get; set; }
    public required string Email { get; set; }
} 