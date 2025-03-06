namespace ShacabService.Models;

// Request models
public class CreateRoleRequest
{
    public required string Name { get; set; }
    public required string Description { get; set; }
}

// Response models
public class RoleInfo
{
    public int RoleId { get; set; }
    public required string Name { get; set; }
    public required string Description { get; set; }
} 