-- GetUserChangeRequests stored procedure
CREATE OR ALTER PROCEDURE [dbo].[GetUserChangeRequests]
    @UserId INT,
    @Status NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate required parameters
    IF @UserId IS NULL
    BEGIN
        RAISERROR('UserId is a required parameter', 16, 1);
        RETURN;
    END
    
    -- Validate that the user exists
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
    BEGIN
        RAISERROR('The specified user does not exist', 16, 1);
        RETURN;
    END
    
    -- Get user roles
    DECLARE @IsAdmin BIT = 0;
    DECLARE @IsCABMember BIT = 0;
    DECLARE @IsSupervisor BIT = 0;
    
    SELECT @IsAdmin = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM UserRoles ur
    INNER JOIN Roles r ON ur.RoleId = r.RoleId
    WHERE ur.UserId = @UserId AND r.Name = 'Admin';
    
    SELECT @IsCABMember = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM UserRoles ur
    INNER JOIN Roles r ON ur.RoleId = r.RoleId
    WHERE ur.UserId = @UserId AND r.Name = 'CABMember';
    
    SELECT @IsSupervisor = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM UserRoles ur
    INNER JOIN Roles r ON ur.RoleId = r.RoleId
    WHERE ur.UserId = @UserId AND r.Name = 'Supervisor';
    
    -- If the user is an admin or CAB member, return all change requests
    IF @IsAdmin = 1 OR @IsCABMember = 1
    BEGIN
        IF @Status IS NULL
        BEGIN
            SELECT 
                cr.ChangeRequestId,
                cr.Title,
                cr.Description,
                cr.Status,
                cr.Priority,
                cr.ImpactLevel,
                cr.RiskLevel,
                cr.ImplementationDate,
                cr.SubmissionDate,
                cr.CreatedDate,
                cr.LastModifiedDate,
                requester.UserId AS RequesterId,
                requester.FirstName + ' ' + requester.LastName AS RequesterName,
                supervisor.UserId AS SupervisorId,
                supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName,
                'Admin' AS AccessType
            FROM 
                ChangeRequests cr
            INNER JOIN 
                Users requester ON cr.RequesterId = requester.UserId
            LEFT JOIN 
                Users supervisor ON cr.SupervisorId = supervisor.UserId
            ORDER BY 
                cr.LastModifiedDate DESC;
        END
        ELSE
        BEGIN
            SELECT 
                cr.ChangeRequestId,
                cr.Title,
                cr.Description,
                cr.Status,
                cr.Priority,
                cr.ImpactLevel,
                cr.RiskLevel,
                cr.ImplementationDate,
                cr.SubmissionDate,
                cr.CreatedDate,
                cr.LastModifiedDate,
                requester.UserId AS RequesterId,
                requester.FirstName + ' ' + requester.LastName AS RequesterName,
                supervisor.UserId AS SupervisorId,
                supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName,
                'Admin' AS AccessType
            FROM 
                ChangeRequests cr
            INNER JOIN 
                Users requester ON cr.RequesterId = requester.UserId
            LEFT JOIN 
                Users supervisor ON cr.SupervisorId = supervisor.UserId
            WHERE 
                cr.Status = @Status
            ORDER BY 
                cr.LastModifiedDate DESC;
        END
    END
    -- If the user is a supervisor, return their own requests and those they supervise
    ELSE IF @IsSupervisor = 1
    BEGIN
        IF @Status IS NULL
        BEGIN
            SELECT 
                cr.ChangeRequestId,
                cr.Title,
                cr.Description,
                cr.Status,
                cr.Priority,
                cr.ImpactLevel,
                cr.RiskLevel,
                cr.ImplementationDate,
                cr.SubmissionDate,
                cr.CreatedDate,
                cr.LastModifiedDate,
                requester.UserId AS RequesterId,
                requester.FirstName + ' ' + requester.LastName AS RequesterName,
                supervisor.UserId AS SupervisorId,
                supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName,
                CASE 
                    WHEN cr.RequesterId = @UserId THEN 'Owner'
                    WHEN cr.SupervisorId = @UserId THEN 'Supervisor'
                    ELSE 'Team'
                END AS AccessType
            FROM 
                ChangeRequests cr
            INNER JOIN 
                Users requester ON cr.RequesterId = requester.UserId
            LEFT JOIN 
                Users supervisor ON cr.SupervisorId = supervisor.UserId
            WHERE 
                cr.RequesterId = @UserId OR 
                cr.SupervisorId = @UserId OR
                cr.RequesterId IN (
                    SELECT UserId FROM Supervisors WHERE SupervisorUserId = @UserId
                )
            ORDER BY 
                cr.LastModifiedDate DESC;
        END
        ELSE
        BEGIN
            SELECT 
                cr.ChangeRequestId,
                cr.Title,
                cr.Description,
                cr.Status,
                cr.Priority,
                cr.ImpactLevel,
                cr.RiskLevel,
                cr.ImplementationDate,
                cr.SubmissionDate,
                cr.CreatedDate,
                cr.LastModifiedDate,
                requester.UserId AS RequesterId,
                requester.FirstName + ' ' + requester.LastName AS RequesterName,
                supervisor.UserId AS SupervisorId,
                supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName,
                CASE 
                    WHEN cr.RequesterId = @UserId THEN 'Owner'
                    WHEN cr.SupervisorId = @UserId THEN 'Supervisor'
                    ELSE 'Team'
                END AS AccessType
            FROM 
                ChangeRequests cr
            INNER JOIN 
                Users requester ON cr.RequesterId = requester.UserId
            LEFT JOIN 
                Users supervisor ON cr.SupervisorId = supervisor.UserId
            WHERE 
                cr.Status = @Status AND
                (cr.RequesterId = @UserId OR 
                 cr.SupervisorId = @UserId OR
                 cr.RequesterId IN (
                     SELECT UserId FROM Supervisors WHERE SupervisorUserId = @UserId
                 ))
            ORDER BY 
                cr.LastModifiedDate DESC;
        END
    END
    -- Otherwise, return only the user's own requests
    ELSE
    BEGIN
        IF @Status IS NULL
        BEGIN
            SELECT 
                cr.ChangeRequestId,
                cr.Title,
                cr.Description,
                cr.Status,
                cr.Priority,
                cr.ImpactLevel,
                cr.RiskLevel,
                cr.ImplementationDate,
                cr.SubmissionDate,
                cr.CreatedDate,
                cr.LastModifiedDate,
                requester.UserId AS RequesterId,
                requester.FirstName + ' ' + requester.LastName AS RequesterName,
                supervisor.UserId AS SupervisorId,
                supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName,
                'Owner' AS AccessType
            FROM 
                ChangeRequests cr
            INNER JOIN 
                Users requester ON cr.RequesterId = requester.UserId
            LEFT JOIN 
                Users supervisor ON cr.SupervisorId = supervisor.UserId
            WHERE 
                cr.RequesterId = @UserId
            ORDER BY 
                cr.LastModifiedDate DESC;
        END
        ELSE
        BEGIN
            SELECT 
                cr.ChangeRequestId,
                cr.Title,
                cr.Description,
                cr.Status,
                cr.Priority,
                cr.ImpactLevel,
                cr.RiskLevel,
                cr.ImplementationDate,
                cr.SubmissionDate,
                cr.CreatedDate,
                cr.LastModifiedDate,
                requester.UserId AS RequesterId,
                requester.FirstName + ' ' + requester.LastName AS RequesterName,
                supervisor.UserId AS SupervisorId,
                supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName,
                'Owner' AS AccessType
            FROM 
                ChangeRequests cr
            INNER JOIN 
                Users requester ON cr.RequesterId = requester.UserId
            LEFT JOIN 
                Users supervisor ON cr.SupervisorId = supervisor.UserId
            WHERE 
                cr.RequesterId = @UserId AND
                cr.Status = @Status
            ORDER BY 
                cr.LastModifiedDate DESC;
        END
    END
END;
GO

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Retrieves change requests associated with a user based on their role and permissions',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'GetUserChangeRequests';
GO
