-- GetChangeRequestDetails stored procedure
CREATE OR ALTER PROCEDURE [dbo].[GetChangeRequestDetails]
    @ChangeRequestId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get the change request details
    SELECT 
        cr.ChangeRequestId,
        cr.Title,
        cr.Description,
        cr.Status,
        cr.Priority,
        cr.ImpactLevel,
        cr.RiskLevel,
        cr.ImplementationDate,
        cr.SubmissionDate,
        cr.ApprovalDate,
        cr.ClosureDate,
        cr.CreatedDate,
        cr.LastModifiedDate,
        requester.UserId AS RequesterId,
        requester.FirstName + ' ' + requester.LastName AS RequesterName,
        requester.Email AS RequesterEmail,
        supervisor.UserId AS SupervisorId,
        supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName,
        supervisor.Email AS SupervisorEmail
    FROM 
        ChangeRequests cr
    INNER JOIN 
        Users requester ON cr.RequesterId = requester.UserId
    LEFT JOIN 
        Users supervisor ON cr.SupervisorId = supervisor.UserId
    WHERE 
        cr.ChangeRequestId = @ChangeRequestId;
    
    -- Get the reviews for this change request
    SELECT 
        r.ReviewId,
        r.ChangeRequestId,
        r.ReviewerId,
        u.FirstName + ' ' + u.LastName AS ReviewerName,
        u.Email AS ReviewerEmail,
        r.Decision,
        r.Comments,
        r.ReviewDate
    FROM 
        Reviews r
    INNER JOIN 
        Users u ON r.ReviewerId = u.UserId
    WHERE 
        r.ChangeRequestId = @ChangeRequestId
    ORDER BY 
        r.ReviewDate DESC;
    
    -- Get the attachments for this change request
    SELECT 
        a.AttachmentId,
        a.ChangeRequestId,
        a.FileName,
        a.FileType,
        a.FileSize,
        a.UploadedBy,
        u.FirstName + ' ' + u.LastName AS UploaderName,
        a.UploadDate,
        a.Description
    FROM 
        Attachments a
    INNER JOIN 
        Users u ON a.UploadedBy = u.UserId
    WHERE 
        a.ChangeRequestId = @ChangeRequestId
    ORDER BY 
        a.UploadDate DESC;
    
    -- Get the support assignments for this change request
    SELECT 
        sa.AssignmentId,
        sa.ChangeRequestId,
        sa.AssignedToId,
        assignee.FirstName + ' ' + assignee.LastName AS AssigneeName,
        assignee.Email AS AssigneeEmail,
        sa.AssignedById,
        assigner.FirstName + ' ' + assigner.LastName AS AssignerName,
        sa.AssignmentDate,
        sa.DueDate,
        sa.Status,
        sa.Notes,
        sa.CompletionDate
    FROM 
        SupportAssignments sa
    INNER JOIN 
        Users assignee ON sa.AssignedToId = assignee.UserId
    INNER JOIN 
        Users assigner ON sa.AssignedById = assigner.UserId
    WHERE 
        sa.ChangeRequestId = @ChangeRequestId
    ORDER BY 
        sa.AssignmentDate DESC;
    
    -- Get the CAB meetings where this change request is discussed
    SELECT 
        m.MeetingId,
        m.Title AS MeetingTitle,
        m.ScheduledDate,
        m.Status AS MeetingStatus,
        mcr.DiscussionOrder,
        mcr.DiscussionDuration,
        mcr.Decision,
        mcr.DecisionNotes,
        mcr.Notes AS DiscussionNotes
    FROM 
        CABMeetingChangeRequests mcr
    INNER JOIN 
        CABMeetings m ON mcr.MeetingId = m.MeetingId
    WHERE 
        mcr.ChangeRequestId = @ChangeRequestId
    ORDER BY 
        m.ScheduledDate DESC;
END;
GO

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Retrieves detailed information for a specific change request including reviews, attachments, support assignments, and related CAB meetings',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'GetChangeRequestDetails';
GO
