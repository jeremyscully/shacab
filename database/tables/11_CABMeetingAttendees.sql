-- CABMeetingAttendees table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CABMeetingAttendees]') AND type in (N'U'))
BEGIN
    CREATE TABLE CABMeetingAttendees (
        AttendeeId INT IDENTITY(1,1) PRIMARY KEY,
        MeetingId INT NOT NULL,
        UserId INT NOT NULL,
        AttendanceStatus NVARCHAR(20) NOT NULL DEFAULT 'Invited', -- Invited, Accepted, Declined, Attended, NoShow
        InvitationDate DATETIME NOT NULL DEFAULT GETDATE(),
        ResponseDate DATETIME NULL,
        Notes NVARCHAR(500) NULL,
        CONSTRAINT FK_CABMeetingAttendees_Meeting FOREIGN KEY (MeetingId) REFERENCES CABMeetings(MeetingId),
        CONSTRAINT FK_CABMeetingAttendees_User FOREIGN KEY (UserId) REFERENCES Users(UserId),
        CONSTRAINT UQ_CABMeetingAttendees_Meeting_User UNIQUE (MeetingId, UserId)
    );

    -- Add indexes for faster lookups
    CREATE INDEX IX_CABMeetingAttendees_MeetingId ON CABMeetingAttendees(MeetingId);
    CREATE INDEX IX_CABMeetingAttendees_UserId ON CABMeetingAttendees(UserId);
    CREATE INDEX IX_CABMeetingAttendees_AttendanceStatus ON CABMeetingAttendees(AttendanceStatus);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores attendee information for Change Advisory Board meetings',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'CABMeetingAttendees';
    
    PRINT 'CABMeetingAttendees table created successfully.';
END
ELSE
BEGIN
    PRINT 'CABMeetingAttendees table already exists.';
END
