-- Reviews table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Reviews]') AND type in (N'U'))
BEGIN
    CREATE TABLE Reviews (
        ReviewId INT IDENTITY(1,1) PRIMARY KEY,
        ChangeRequestId INT NOT NULL,
        ReviewerId INT NOT NULL,
        Decision NVARCHAR(20) NOT NULL, -- Approved, Rejected, MoreInfo
        Comments NVARCHAR(MAX) NULL,
        ReviewDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Reviews_ChangeRequest FOREIGN KEY (ChangeRequestId) REFERENCES ChangeRequests(ChangeRequestId),
        CONSTRAINT FK_Reviews_Reviewer FOREIGN KEY (ReviewerId) REFERENCES Users(UserId),
        CONSTRAINT UQ_Reviews_ChangeRequest_Reviewer UNIQUE (ChangeRequestId, ReviewerId)
    );

    -- Add indexes for faster lookups
    CREATE INDEX IX_Reviews_ChangeRequestId ON Reviews(ChangeRequestId);
    CREATE INDEX IX_Reviews_ReviewerId ON Reviews(ReviewerId);
    CREATE INDEX IX_Reviews_Decision ON Reviews(Decision);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores reviews and decisions for change requests',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'Reviews';
    
    PRINT 'Reviews table created successfully.';
END
ELSE
BEGIN
    PRINT 'Reviews table already exists.';
END
