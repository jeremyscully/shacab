-- Attachments table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Attachments]') AND type in (N'U'))
BEGIN
    CREATE TABLE Attachments (
        AttachmentId INT IDENTITY(1,1) PRIMARY KEY,
        ChangeRequestId INT NOT NULL,
        FileName NVARCHAR(255) NOT NULL,
        FileType NVARCHAR(100) NOT NULL,
        FileSize INT NOT NULL,
        FileContent VARBINARY(MAX) NOT NULL,
        UploadedBy INT NOT NULL,
        UploadDate DATETIME NOT NULL DEFAULT GETDATE(),
        Description NVARCHAR(500) NULL,
        CONSTRAINT FK_Attachments_ChangeRequest FOREIGN KEY (ChangeRequestId) REFERENCES ChangeRequests(ChangeRequestId),
        CONSTRAINT FK_Attachments_UploadedBy FOREIGN KEY (UploadedBy) REFERENCES Users(UserId)
    );

    -- Add indexes for faster lookups
    CREATE INDEX IX_Attachments_ChangeRequestId ON Attachments(ChangeRequestId);
    CREATE INDEX IX_Attachments_UploadedBy ON Attachments(UploadedBy);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores file attachments for change requests',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'Attachments';
    
    PRINT 'Attachments table created successfully.';
END
ELSE
BEGIN
    PRINT 'Attachments table already exists.';
END
