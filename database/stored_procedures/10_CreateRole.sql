-- CreateRole stored procedure
CREATE OR ALTER PROCEDURE [dbo].[CreateRole]
    @Name NVARCHAR(50),
    @Description NVARCHAR(255),
    @RoleId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate required parameters
    IF @Name IS NULL OR @Description IS NULL
    BEGIN
        RAISERROR('Name and Description are required parameters', 16, 1);
        RETURN;
    END
    
    -- Check if role name already exists
    IF EXISTS (SELECT 1 FROM Roles WHERE Name = @Name)
    BEGIN
        RAISERROR('A role with this name already exists', 16, 1);
        RETURN;
    END
    
    BEGIN TRY
        -- Insert the new role
        INSERT INTO Roles (
            Name,
            Description
        )
        VALUES (
            @Name,
            @Description
        );
        
        -- Get the ID of the newly created role
        SET @RoleId = SCOPE_IDENTITY();
        
        -- Return the newly created role
        SELECT 
            RoleId,
            Name,
            Description
        FROM 
            Roles
        WHERE 
            RoleId = @RoleId;
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
    @value = N'Creates a new role in the system',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'CreateRole';
GO 