using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ShacabService.Services;
using ShacabService.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

// Add database service
builder.Services.AddSingleton<IDatabaseService>(provider =>
{
    var configuration = provider.GetRequiredService<IConfiguration>();
    var connectionString = configuration.GetConnectionString("ShacabDatabase");
    return new DatabaseService(connectionString);
});

// Add repositories
builder.Services.AddScoped<IChangeRequestRepository, ChangeRequestRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IRoleRepository, RoleRepository>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");

// Map endpoints
MapChangeRequestEndpoints(app);
MapUserEndpoints(app);
MapRoleEndpoints(app);

app.Run();

// Endpoint mapping methods
void MapChangeRequestEndpoints(WebApplication app)
{
    var group = app.MapGroup("/api/change-requests");

    // Get change requests by status
    group.MapGet("/", async (IChangeRequestRepository repository, [FromQuery] string? status) =>
    {
        try
        {
            var changeRequests = await repository.GetChangeRequestsByStatusAsync(status);
            return Results.Ok(changeRequests);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("GetChangeRequestsByStatus")
    .WithOpenApi();

    // Get change request details
    group.MapGet("/{id}", async (IChangeRequestRepository repository, int id) =>
    {
        try
        {
            var result = await repository.GetChangeRequestDetailsAsync(id);
            if (result == null)
                return Results.NotFound($"Change request with ID {id} not found");

            return Results.Ok(result);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("GetChangeRequestDetails")
    .WithOpenApi();

    // Create change request
    group.MapPost("/", async (IChangeRequestRepository repository, CreateChangeRequestRequest request) =>
    {
        try
        {
            var changeRequestId = await repository.CreateChangeRequestAsync(
                request.Title,
                request.Description,
                request.RequesterId,
                request.SupervisorId,
                request.Priority,
                request.ImpactLevel,
                request.RiskLevel,
                request.ImplementationDate,
                request.Status);

            var changeRequest = await repository.GetChangeRequestDetailsAsync(changeRequestId);
            return Results.Created($"/api/change-requests/{changeRequestId}", changeRequest);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("CreateChangeRequest")
    .WithOpenApi();

    // Update change request status
    group.MapPut("/{id}/status", async (IChangeRequestRepository repository, int id, UpdateChangeRequestStatusRequest request) =>
    {
        try
        {
            var changeRequest = await repository.UpdateChangeRequestStatusAsync(
                id,
                request.Status,
                request.UserId,
                request.Comments);

            if (changeRequest == null)
                return Results.NotFound($"Change request with ID {id} not found");

            return Results.Ok(changeRequest);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("UpdateChangeRequestStatus")
    .WithOpenApi();

    // Get user change requests
    group.MapGet("/user/{userId}", async (IChangeRequestRepository repository, int userId, [FromQuery] string? status) =>
    {
        try
        {
            var changeRequests = await repository.GetUserChangeRequestsAsync(userId, status);
            return Results.Ok(changeRequests);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("GetUserChangeRequests")
    .WithOpenApi();
}

void MapUserEndpoints(WebApplication app)
{
    var group = app.MapGroup("/api/users");

    // Get all users
    group.MapGet("/", async (IUserRepository repository, [FromQuery] bool includeInactive = false, [FromQuery] string? searchTerm = null, [FromQuery] string? department = null, [FromQuery] int? roleId = null) =>
    {
        try
        {
            var users = await repository.GetAllUsersAsync(includeInactive, searchTerm, department, roleId);
            return Results.Ok(users);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("GetAllUsers")
    .WithOpenApi();

    // Get user details
    group.MapGet("/{id}", async (IUserRepository repository, int id) =>
    {
        try
        {
            var result = await repository.GetUserDetailsAsync(id);
            if (result == null)
                return Results.NotFound($"User with ID {id} not found");

            return Results.Ok(result);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("GetUserDetails")
    .WithOpenApi();

    // Get user details by username
    group.MapGet("/by-username/{username}", async (IUserRepository repository, string username) =>
    {
        try
        {
            var result = await repository.GetUserDetailsByUsernameAsync(username);
            if (result == null)
                return Results.NotFound($"User with username {username} not found");

            return Results.Ok(result);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("GetUserDetailsByUsername")
    .WithOpenApi();

    // Create user
    group.MapPost("/", async (IUserRepository repository, CreateUserRequest request) =>
    {
        try
        {
            var userId = await repository.CreateUserAsync(
                request.Username,
                request.Email,
                request.PasswordHash,
                request.FirstName,
                request.LastName,
                request.Department,
                request.RoleIds);

            var user = await repository.GetUserDetailsAsync(userId);
            return Results.Created($"/api/users/{userId}", user);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("CreateUser")
    .WithOpenApi();

    // Update user
    group.MapPut("/{id}", async (IUserRepository repository, int id, UpdateUserRequest request) =>
    {
        try
        {
            var user = await repository.UpdateUserAsync(
                id,
                request.Email,
                request.PasswordHash,
                request.FirstName,
                request.LastName,
                request.Department,
                request.IsActive);

            if (user == null)
                return Results.NotFound($"User with ID {id} not found");

            return Results.Ok(user);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("UpdateUser")
    .WithOpenApi();

    // Manage user roles
    group.MapPut("/{id}/roles", async (IUserRepository repository, int id, ManageUserRolesRequest request) =>
    {
        try
        {
            var roles = await repository.ManageUserRolesAsync(
                id,
                request.RoleIds,
                request.Action);

            if (roles == null)
                return Results.NotFound($"User with ID {id} not found");

            return Results.Ok(roles);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("ManageUserRoles")
    .WithOpenApi();
}

void MapRoleEndpoints(WebApplication app)
{
    var group = app.MapGroup("/api/roles");

    // Create role
    group.MapPost("/", async (IRoleRepository repository, CreateRoleRequest request) =>
    {
        try
        {
            var roleId = await repository.CreateRoleAsync(
                request.Name,
                request.Description);

            var role = await repository.GetRoleAsync(roleId);
            return Results.Created($"/api/roles/{roleId}", role);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("CreateRole")
    .WithOpenApi();

    // Get all roles
    group.MapGet("/", async (IRoleRepository repository) =>
    {
        try
        {
            var roles = await repository.GetAllRolesAsync();
            return Results.Ok(roles);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("GetAllRoles")
    .WithOpenApi();

    // Get role by ID
    group.MapGet("/{id}", async (IRoleRepository repository, int id) =>
    {
        try
        {
            var role = await repository.GetRoleAsync(id);
            if (role == null)
                return Results.NotFound($"Role with ID {id} not found");

            return Results.Ok(role);
        }
        catch (Exception ex)
        {
            return Results.Problem(ex.Message);
        }
    })
    .WithName("GetRole")
    .WithOpenApi();
} 