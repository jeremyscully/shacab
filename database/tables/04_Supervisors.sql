-- Supervisors table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Supervisors]') AND type in (N'U'))
BEGIN
    CREATE TABLE Supervisors (
        SupervisorId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        SupervisorUserId INT NOT NULL,
        Department NVARCHAR(100) NOT NULL,
        AssignedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Supervisors_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
        CONSTRAINT FK_Supervisors_SupervisorUsers FOREIGN KEY (SupervisorUserId) REFERENCES Users(UserId),
        CONSTRAINT UQ_Supervisors_UserSupervisor UNIQUE (UserId, SupervisorUserId)
    );

    -- Add indexes for faster lookups and joins
    CREATE INDEX IX_Supervisors_UserId ON Supervisors(UserId);
    CREATE INDEX IX_Supervisors_SupervisorUserId ON Supervisors(SupervisorUserId);
    CREATE INDEX IX_Supervisors_Department ON Supervisors(Department);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores supervisor relationships between users',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'Supervisors';
    
    PRINT 'Supervisors table created successfully.';
END
ELSE
BEGIN
    PRINT 'Supervisors table already exists.';
END
