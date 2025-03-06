-- CABMeetings table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CABMeetings]') AND type in (N'U'))
BEGIN
    CREATE TABLE CABMeetings (
        MeetingId INT IDENTITY(1,1) PRIMARY KEY,
        Title NVARCHAR(100) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        ScheduledDate DATETIME NOT NULL,
        Duration INT NOT NULL, -- Duration in minutes
        Location NVARCHAR(255) NULL,
        VirtualMeetingUrl NVARCHAR(255) NULL,
        OrganizerId INT NOT NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Scheduled', -- Scheduled, InProgress, Completed, Cancelled
        Agenda NVARCHAR(MAX) NULL,
        Minutes NVARCHAR(MAX) NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        LastModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_CABMeetings_Organizer FOREIGN KEY (OrganizerId) REFERENCES Users(UserId)
    );

    -- Add indexes for faster lookups
    CREATE INDEX IX_CABMeetings_ScheduledDate ON CABMeetings(ScheduledDate);
    CREATE INDEX IX_CABMeetings_OrganizerId ON CABMeetings(OrganizerId);
    CREATE INDEX IX_CABMeetings_Status ON CABMeetings(Status);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores Change Advisory Board meeting information',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'CABMeetings';
    
    PRINT 'CABMeetings table created successfully.';
END
ELSE
BEGIN
    PRINT 'CABMeetings table already exists.';
END
