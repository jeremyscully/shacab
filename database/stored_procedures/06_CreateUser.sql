-- CreateUser stored procedure
CREATE OR ALTER PROCEDURE [dbo].[CreateUser]
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @PasswordHash NVARCHAR(128),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Department NVARCHAR(50) = NULL,
    @RoleIds NVARCHAR(MAX) = NULL, -- Comma-separated list of role IDs
    @UserId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate required parameters
    IF @Username IS NULL OR @Email IS NULL OR @PasswordHash IS NULL OR @FirstName IS NULL OR @LastName IS NULL
    BEGIN
        RAISERROR('Username, Email, PasswordHash, FirstName, and LastName are required parameters', 16, 1);
        RETURN;
    END
    
    -- Check if username already exists
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        RAISERROR('A user with this username already exists', 16, 1);
        RETURN;
    END
    
    -- Check if email already exists
    IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
    BEGIN
        RAISERROR('A user with this email already exists', 16, 1);
        RETURN;
    END
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insert the new user
        INSERT INTO Users (
            Username,
            Email,
            PasswordHash,
            FirstName,
            LastName,
            Department,
            IsActive,
            CreatedDate
        )
        VALUES (
            @Username,
            @Email,
            @PasswordHash,
            @FirstName,
            @LastName,
            @Department,
            1, -- IsActive = true
            GETDATE()
        );
        
        -- Get the ID of the newly created user
        SET @UserId = SCOPE_IDENTITY();
        
        -- Assign roles if provided
        IF @RoleIds IS NOT NULL AND LEN(@RoleIds) > 0
        BEGIN
            -- Create a temporary table to hold the role IDs
            CREATE TABLE #TempRoles (RoleId INT);
            
            -- Split the comma-separated list and insert into the temp table
            INSERT INTO #TempRoles (RoleId)
            SELECT value FROM STRING_SPLIT(@RoleIds, ',');
            
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
            
            -- Assign the roles to the user
            INSERT INTO UserRoles (UserId, RoleId, AssignedDate)
            SELECT @UserId, RoleId, GETDATE()
            FROM #TempRoles;
            
            -- Clean up the temporary table
            DROP TABLE #TempRoles;
        END
        ELSE
        BEGIN
            -- If no roles specified, assign the default 'User' role
            DECLARE @DefaultRoleId INT;
            
            SELECT @DefaultRoleId = RoleId
            FROM Roles
            WHERE Name = 'User';
            
            IF @DefaultRoleId IS NOT NULL
            BEGIN
                INSERT INTO UserRoles (UserId, RoleId, AssignedDate)
                VALUES (@UserId, @DefaultRoleId, GETDATE());
            END
        END
        
        COMMIT TRANSACTION;
        
        -- Return the newly created user
        SELECT 
            u.UserId,
            u.Username,
            u.Email,
            u.FirstName,
            u.LastName,
            u.Department,
            u.IsActive,
            u.CreatedDate,
            u.LastLoginDate,
            STRING_AGG(r.Name, ', ') AS Roles
        FROM 
            Users u
        LEFT JOIN 
            UserRoles ur ON u.UserId = ur.UserId
        LEFT JOIN 
            Roles r ON ur.RoleId = r.RoleId
        WHERE 
            u.UserId = @UserId
        GROUP BY 
            u.UserId, u.Username, u.Email, u.FirstName, u.LastName, u.Department, u.IsActive, u.CreatedDate, u.LastLoginDate;
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
    @value = N'Creates a new user account with specified roles',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'CreateUser';
GO 