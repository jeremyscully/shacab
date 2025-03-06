-- UpdateUser stored procedure
CREATE OR ALTER PROCEDURE [dbo].[UpdateUser]
    @UserId INT,
    @Email NVARCHAR(100) = NULL,
    @PasswordHash NVARCHAR(128) = NULL,
    @FirstName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @Department NVARCHAR(50) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate required parameters
    IF @UserId IS NULL
    BEGIN
        RAISERROR('UserId is a required parameter', 16, 1);
        RETURN;
    END
    
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
    BEGIN
        RAISERROR('The specified user does not exist', 16, 1);
        RETURN;
    END
    
    -- Check if email already exists (if email is being updated)
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM Users WHERE Email = @Email AND UserId <> @UserId)
    BEGIN
        RAISERROR('A user with this email already exists', 16, 1);
        RETURN;
    END
    
    BEGIN TRY
        -- Update the user
        UPDATE Users
        SET 
            Email = ISNULL(@Email, Email),
            PasswordHash = ISNULL(@PasswordHash, PasswordHash),
            FirstName = ISNULL(@FirstName, FirstName),
            LastName = ISNULL(@LastName, LastName),
            Department = ISNULL(@Department, Department),
            IsActive = ISNULL(@IsActive, IsActive)
        WHERE 
            UserId = @UserId;
        
        -- Return the updated user
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
    @value = N'Updates an existing user account',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'UpdateUser';
GO 