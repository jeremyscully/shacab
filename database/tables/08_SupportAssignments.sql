-- SupportAssignments table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SupportAssignments]') AND type in (N'U'))
BEGIN
    CREATE TABLE SupportAssignments (
        AssignmentId INT IDENTITY(1,1) PRIMARY KEY,
        ChangeRequestId INT NOT NULL,
        AssignedToId INT NOT NULL,
        AssignedById INT NOT NULL,
        AssignmentDate DATETIME NOT NULL DEFAULT GETDATE(),
        DueDate DATETIME NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Assigned', -- Assigned, InProgress, Completed, Cancelled
        Notes NVARCHAR(MAX) NULL,
        CompletionDate DATETIME NULL,
        CONSTRAINT FK_SupportAssignments_ChangeRequest FOREIGN KEY (ChangeRequestId) REFERENCES ChangeRequests(ChangeRequestId),
        CONSTRAINT FK_SupportAssignments_AssignedTo FOREIGN KEY (AssignedToId) REFERENCES Users(UserId),
        CONSTRAINT FK_SupportAssignments_AssignedBy FOREIGN KEY (AssignedById) REFERENCES Users(UserId)
    );

    -- Add indexes for faster lookups
    CREATE INDEX IX_SupportAssignments_ChangeRequestId ON SupportAssignments(ChangeRequestId);
    CREATE INDEX IX_SupportAssignments_AssignedToId ON SupportAssignments(AssignedToId);
    CREATE INDEX IX_SupportAssignments_Status ON SupportAssignments(Status);
    CREATE INDEX IX_SupportAssignments_DueDate ON SupportAssignments(DueDate);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores support assignments for change requests',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'SupportAssignments';
    
    PRINT 'SupportAssignments table created successfully.';
END
ELSE
BEGIN
    PRINT 'SupportAssignments table already exists.';
END
