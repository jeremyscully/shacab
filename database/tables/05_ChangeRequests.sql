-- ChangeRequests table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChangeRequests]') AND type in (N'U'))
BEGIN
    CREATE TABLE ChangeRequests (
        ChangeRequestId INT IDENTITY(1,1) PRIMARY KEY,
        Title NVARCHAR(100) NOT NULL,
        Description NVARCHAR(MAX) NOT NULL,
        RequesterId INT NOT NULL,
        SupervisorId INT NULL,
        Status NVARCHAR(50) NOT NULL DEFAULT 'Draft', -- Draft, Submitted, InReview, Approved, Rejected, Implemented, Closed
        Priority NVARCHAR(20) NOT NULL DEFAULT 'Medium', -- Low, Medium, High, Critical
        ImpactLevel NVARCHAR(20) NOT NULL DEFAULT 'Medium', -- Low, Medium, High
        RiskLevel NVARCHAR(20) NOT NULL DEFAULT 'Medium', -- Low, Medium, High
        ImplementationDate DATETIME NULL,
        SubmissionDate DATETIME NULL,
        ApprovalDate DATETIME NULL,
        ClosureDate DATETIME NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        LastModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_ChangeRequests_Requester FOREIGN KEY (RequesterId) REFERENCES Users(UserId),
        CONSTRAINT FK_ChangeRequests_Supervisor FOREIGN KEY (SupervisorId) REFERENCES Users(UserId)
    );

    -- Add indexes for faster lookups and filtering
    CREATE INDEX IX_ChangeRequests_Status ON ChangeRequests(Status);
    CREATE INDEX IX_ChangeRequests_RequesterId ON ChangeRequests(RequesterId);
    CREATE INDEX IX_ChangeRequests_SupervisorId ON ChangeRequests(SupervisorId);
    CREATE INDEX IX_ChangeRequests_Priority ON ChangeRequests(Priority);
    CREATE INDEX IX_ChangeRequests_ImplementationDate ON ChangeRequests(ImplementationDate);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores change request information for the Change Advisory Board system',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'ChangeRequests';
    
    PRINT 'ChangeRequests table created successfully.';
END
ELSE
BEGIN
    PRINT 'ChangeRequests table already exists.';
END
