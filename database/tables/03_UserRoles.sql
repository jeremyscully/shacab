-- UserRoles junction table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserRoles]') AND type in (N'U'))
BEGIN
    CREATE TABLE UserRoles (
        UserRoleId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        RoleId INT NOT NULL,
        AssignedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
        CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId),
        CONSTRAINT UQ_UserRoles_UserRole UNIQUE (UserId, RoleId)
    );

    -- Add indexes for faster lookups and joins
    CREATE INDEX IX_UserRoles_UserId ON UserRoles(UserId);
    CREATE INDEX IX_UserRoles_RoleId ON UserRoles(RoleId);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Junction table linking users to their assigned roles',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'UserRoles';
    
    PRINT 'UserRoles table created successfully.';
END
ELSE
BEGIN
    PRINT 'UserRoles table already exists.';
END
