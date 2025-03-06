-- Notifications table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Notifications]') AND type in (N'U'))
BEGIN
    CREATE TABLE Notifications (
        NotificationId INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        Title NVARCHAR(100) NOT NULL,
        Message NVARCHAR(MAX) NOT NULL,
        NotificationType NVARCHAR(50) NOT NULL, -- ChangeRequest, Review, Assignment, Meeting, System
        RelatedEntityId INT NULL, -- ID of the related entity (ChangeRequestId, ReviewId, etc.)
        IsRead BIT NOT NULL DEFAULT 0,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        ReadDate DATETIME NULL,
        CONSTRAINT FK_Notifications_User FOREIGN KEY (UserId) REFERENCES Users(UserId)
    );

    -- Add indexes for faster lookups
    CREATE INDEX IX_Notifications_UserId ON Notifications(UserId);
    CREATE INDEX IX_Notifications_IsRead ON Notifications(IsRead);
    CREATE INDEX IX_Notifications_NotificationType ON Notifications(NotificationType);
    CREATE INDEX IX_Notifications_CreatedDate ON Notifications(CreatedDate);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores notifications for users',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'Notifications';
    
    PRINT 'Notifications table created successfully.';
END
ELSE
BEGIN
    PRINT 'Notifications table already exists.';
END
