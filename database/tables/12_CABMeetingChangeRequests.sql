-- CABMeetingChangeRequests table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CABMeetingChangeRequests]') AND type in (N'U'))
BEGIN
    CREATE TABLE CABMeetingChangeRequests (
        MeetingChangeRequestId INT IDENTITY(1,1) PRIMARY KEY,
        MeetingId INT NOT NULL,
        ChangeRequestId INT NOT NULL,
        DiscussionOrder INT NULL, -- Order in which change requests will be discussed
        DiscussionDuration INT NULL, -- Estimated discussion time in minutes
        Notes NVARCHAR(MAX) NULL,
        Decision NVARCHAR(20) NULL, -- Approved, Rejected, Deferred, MoreInfo
        DecisionNotes NVARCHAR(MAX) NULL,
        AddedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_CABMeetingChangeRequests_Meeting FOREIGN KEY (MeetingId) REFERENCES CABMeetings(MeetingId),
        CONSTRAINT FK_CABMeetingChangeRequests_ChangeRequest FOREIGN KEY (ChangeRequestId) REFERENCES ChangeRequests(ChangeRequestId),
        CONSTRAINT UQ_CABMeetingChangeRequests_Meeting_ChangeRequest UNIQUE (MeetingId, ChangeRequestId)
    );

    -- Add indexes for faster lookups
    CREATE INDEX IX_CABMeetingChangeRequests_MeetingId ON CABMeetingChangeRequests(MeetingId);
    CREATE INDEX IX_CABMeetingChangeRequests_ChangeRequestId ON CABMeetingChangeRequests(ChangeRequestId);
    CREATE INDEX IX_CABMeetingChangeRequests_Decision ON CABMeetingChangeRequests(Decision);

    -- Add comments
    EXEC sp_addextendedproperty 
        @name = N'MS_Description',
        @value = N'Stores change requests to be discussed in CAB meetings',
        @level0type = N'SCHEMA', @level0name = 'dbo',
        @level1type = N'TABLE',  @level1name = 'CABMeetingChangeRequests';
    
    PRINT 'CABMeetingChangeRequests table created successfully.';
END
ELSE
BEGIN
    PRINT 'CABMeetingChangeRequests table already exists.';
END
