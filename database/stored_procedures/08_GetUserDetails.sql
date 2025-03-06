-- GetUserDetails stored procedure
CREATE OR ALTER PROCEDURE [dbo].[GetUserDetails]
    @UserId INT = NULL,
    @Username NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate parameters
    IF @UserId IS NULL AND @Username IS NULL
    BEGIN
        RAISERROR('Either UserId or Username must be provided', 16, 1);
        RETURN;
    END
    
    -- Get user by ID or username
    SELECT 
        u.UserId,
        u.Username,
        u.Email,
        u.FirstName,
        u.LastName,
        u.Department,
        u.IsActive,
        u.CreatedDate,
        u.LastLoginDate
    FROM 
        Users u
    WHERE 
        (@UserId IS NOT NULL AND u.UserId = @UserId) OR
        (@Username IS NOT NULL AND u.Username = @Username);
    
    -- Get user roles
    SELECT 
        r.RoleId,
        r.Name AS RoleName,
        r.Description AS RoleDescription,
        ur.AssignedDate
    FROM 
        UserRoles ur
    INNER JOIN 
        Roles r ON ur.RoleId = r.RoleId
    INNER JOIN 
        Users u ON ur.UserId = u.UserId
    WHERE 
        (@UserId IS NOT NULL AND u.UserId = @UserId) OR
        (@Username IS NOT NULL AND u.Username = @Username)
    ORDER BY 
        r.Name;
    
    -- Get supervisor relationships
    SELECT 
        s.SupervisorId,
        s.Department,
        s.AssignedDate,
        supervisor.UserId AS SupervisorUserId,
        supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName,
        supervisor.Email AS SupervisorEmail
    FROM 
        Supervisors s
    INNER JOIN 
        Users u ON s.UserId = u.UserId
    INNER JOIN 
        Users supervisor ON s.SupervisorUserId = supervisor.UserId
    WHERE 
        (@UserId IS NOT NULL AND s.UserId = @UserId) OR
        (@Username IS NOT NULL AND u.Username = @Username)
    ORDER BY 
        s.Department;
    
    -- Get users supervised by this user
    SELECT 
        s.SupervisorId,
        s.Department,
        s.AssignedDate,
        supervisee.UserId AS SuperviseeUserId,
        supervisee.FirstName + ' ' + supervisee.LastName AS SuperviseeName,
        supervisee.Email AS SuperviseeEmail
    FROM 
        Supervisors s
    INNER JOIN 
        Users u ON s.SupervisorUserId = u.UserId
    INNER JOIN 
        Users supervisee ON s.UserId = supervisee.UserId
    WHERE 
        (@UserId IS NOT NULL AND s.SupervisorUserId = @UserId) OR
        (@Username IS NOT NULL AND u.Username = @Username)
    ORDER BY 
        s.Department, supervisee.LastName, supervisee.FirstName;
    
    -- Get recent change requests
    SELECT TOP 10
        cr.ChangeRequestId,
        cr.Title,
        cr.Status,
        cr.Priority,
        cr.SubmissionDate,
        cr.LastModifiedDate
    FROM 
        ChangeRequests cr
    INNER JOIN 
        Users u ON cr.RequesterId = u.UserId
    WHERE 
        (@UserId IS NOT NULL AND cr.RequesterId = @UserId) OR
        (@Username IS NOT NULL AND u.Username = @Username)
    ORDER BY 
        cr.LastModifiedDate DESC;
END;
GO

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Retrieves detailed information about a user including roles, supervisor relationships, and recent change requests',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'GetUserDetails';
GO 