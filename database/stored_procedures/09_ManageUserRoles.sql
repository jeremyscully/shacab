-- ManageUserRoles stored procedure
CREATE OR ALTER PROCEDURE [dbo].[ManageUserRoles]
    @UserId INT,
    @RoleIds NVARCHAR(MAX), -- Comma-separated list of role IDs
    @Action NVARCHAR(10) -- 'Add', 'Remove', or 'Set'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate required parameters
    IF @UserId IS NULL OR @RoleIds IS NULL OR @Action IS NULL
    BEGIN
        RAISERROR('UserId, RoleIds, and Action are required parameters', 16, 1);
        RETURN;
    END
    
    -- Validate action
    IF @Action NOT IN ('Add', 'Remove', 'Set')
    BEGIN
        RAISERROR('Action must be one of: Add, Remove, Set', 16, 1);
        RETURN;
    END
    
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
    BEGIN
        RAISERROR('The specified user does not exist', 16, 1);
        RETURN;
    END
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Create a temporary table to hold the role IDs
        CREATE TABLE #TempRoles (RoleId INT);
        
        -- Split the comma-separated list and insert into the temp table
        INSERT INTO #TempRoles (RoleId)
        SELECT CAST(value AS INT) FROM STRING_SPLIT(@RoleIds, ',');
        
        -- Validate that all role IDs exist
        IF EXISTS (
            SELECT 1 FROM #TempRoles t
            LEFT JOIN Roles r ON t.RoleId = r.RoleId
            WHERE r.RoleId IS NULL
        )
        BEGIN
            DROP TABLE #TempRoles;
            RAISERROR('One or more of the specified role IDs do not exist', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Perform the requested action
        IF @Action = 'Add'
        BEGIN
            -- Add roles that don't already exist for the user
            INSERT INTO UserRoles (UserId, RoleId, AssignedDate)
            SELECT @UserId, t.RoleId, GETDATE()
            FROM #TempRoles t
            WHERE NOT EXISTS (
                SELECT 1 FROM UserRoles ur
                WHERE ur.UserId = @UserId AND ur.RoleId = t.RoleId
            );
        END
        ELSE IF @Action = 'Remove'
        BEGIN
            -- Remove specified roles from the user
            DELETE ur
            FROM UserRoles ur
            INNER JOIN #TempRoles t ON ur.RoleId = t.RoleId
            WHERE ur.UserId = @UserId;
        END
        ELSE IF @Action = 'Set'
        BEGIN
            -- Remove all existing roles
            DELETE FROM UserRoles WHERE UserId = @UserId;
            
            -- Add the specified roles
            INSERT INTO UserRoles (UserId, RoleId, AssignedDate)
            SELECT @UserId, RoleId, GETDATE()
            FROM #TempRoles;
        END
        
        -- Clean up the temporary table
        DROP TABLE #TempRoles;
        
        COMMIT TRANSACTION;
        
        -- Return the updated user roles
        SELECT 
            u.UserId,
            u.Username,
            u.FirstName + ' ' + u.LastName AS FullName,
            r.RoleId,
            r.Name AS RoleName,
            r.Description AS RoleDescription,
            ur.AssignedDate
        FROM 
            Users u
        INNER JOIN 
            UserRoles ur ON u.UserId = ur.UserId
        INNER JOIN 
            Roles r ON ur.RoleId = r.RoleId
        WHERE 
            u.UserId = @UserId
        ORDER BY 
            r.Name;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Manages user roles by adding, removing, or setting roles for a user',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'ManageUserRoles';
GO 