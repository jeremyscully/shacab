-- GetAllUsers stored procedure
CREATE OR ALTER PROCEDURE [dbo].[GetAllUsers]
    @IncludeInactive BIT = 0,
    @SearchTerm NVARCHAR(100) = NULL,
    @Department NVARCHAR(50) = NULL,
    @RoleId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Build the query dynamically based on parameters
    SELECT DISTINCT
        u.UserId,
        u.Username,
        u.Email,
        u.FirstName,
        u.LastName,
        u.FirstName + ' ' + u.LastName AS FullName,
        u.Department,
        u.IsActive,
        u.CreatedDate,
        u.LastLoginDate,
        STRING_AGG(r.Name, ', ') WITHIN GROUP (ORDER BY r.Name) AS Roles
    FROM 
        Users u
    LEFT JOIN 
        UserRoles ur ON u.UserId = ur.UserId
    LEFT JOIN 
        Roles r ON ur.RoleId = r.RoleId
    WHERE 
        (@IncludeInactive = 1 OR u.IsActive = 1) AND
        (@SearchTerm IS NULL OR 
         u.Username LIKE '%' + @SearchTerm + '%' OR 
         u.Email LIKE '%' + @SearchTerm + '%' OR 
         u.FirstName LIKE '%' + @SearchTerm + '%' OR 
         u.LastName LIKE '%' + @SearchTerm + '%') AND
        (@Department IS NULL OR u.Department = @Department) AND
        (@RoleId IS NULL OR EXISTS (
            SELECT 1 FROM UserRoles ur2 
            WHERE ur2.UserId = u.UserId AND ur2.RoleId = @RoleId
        ))
    GROUP BY
        u.UserId,
        u.Username,
        u.Email,
        u.FirstName,
        u.LastName,
        u.Department,
        u.IsActive,
        u.CreatedDate,
        u.LastLoginDate
    ORDER BY 
        u.LastName, u.FirstName;
END;
GO

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Retrieves all users with optional filtering by active status, search term, department, or role',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'GetAllUsers';
GO 