-- UpdateChangeRequestStatus stored procedure
CREATE OR ALTER PROCEDURE [dbo].[UpdateChangeRequestStatus]
    @ChangeRequestId INT,
    @Status NVARCHAR(50),
    @UserId INT,
    @Comments NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate required parameters
    IF @ChangeRequestId IS NULL OR @Status IS NULL OR @UserId IS NULL
    BEGIN
        RAISERROR('ChangeRequestId, Status, and UserId are required parameters', 16, 1);
        RETURN;
    END
    
    -- Validate that the change request exists
    IF NOT EXISTS (SELECT 1 FROM ChangeRequests WHERE ChangeRequestId = @ChangeRequestId)
    BEGIN
        RAISERROR('The specified change request does not exist', 16, 1);
        RETURN;
    END
    
    -- Validate that the user exists
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
    BEGIN
        RAISERROR('The specified user does not exist', 16, 1);
        RETURN;
    END
    
    -- Get the current status of the change request
    DECLARE @CurrentStatus NVARCHAR(50);
    DECLARE @RequesterId INT;
    DECLARE @SupervisorId INT;
    DECLARE @Title NVARCHAR(100);
    
    SELECT 
        @CurrentStatus = Status,
        @RequesterId = RequesterId,
        @SupervisorId = SupervisorId,
        @Title = Title
    FROM 
        ChangeRequests
    WHERE 
        ChangeRequestId = @ChangeRequestId;
    
    -- Validate the status transition
    IF @CurrentStatus = @Status
    BEGIN
        RAISERROR('The change request is already in the specified status', 16, 1);
        RETURN;
    END
    
    -- Update the change request status
    UPDATE ChangeRequests
    SET 
        Status = @Status,
        LastModifiedDate = GETDATE(),
        SubmissionDate = CASE 
                            WHEN @Status = 'Submitted' AND SubmissionDate IS NULL THEN GETDATE() 
                            ELSE SubmissionDate 
                         END,
        ApprovalDate = CASE 
                          WHEN @Status = 'Approved' THEN GETDATE() 
                          ELSE ApprovalDate 
                       END,
        ClosureDate = CASE 
                         WHEN @Status = 'Closed' THEN GETDATE() 
                         ELSE ClosureDate 
                      END
    WHERE 
        ChangeRequestId = @ChangeRequestId;
    
    -- Create a review record if appropriate
    IF @Status IN ('Approved', 'Rejected', 'MoreInfo')
    BEGIN
        INSERT INTO Reviews (
            ChangeRequestId,
            ReviewerId,
            Decision,
            Comments,
            ReviewDate
        )
        VALUES (
            @ChangeRequestId,
            @UserId,
            @Status,
            @Comments,
            GETDATE()
        );
    END
    
    -- Create notifications based on the status change
    
    -- Notify the requester about the status change
    INSERT INTO Notifications (
        UserId,
        Title,
        Message,
        NotificationType,
        RelatedEntityId,
        IsRead,
        CreatedDate
    )
    VALUES (
        @RequesterId,
        'Change Request Status Updated',
        'Your change request "' + @Title + '" has been updated to status: ' + @Status,
        'ChangeRequest',
        @ChangeRequestId,
        0,
        GETDATE()
    );
    
    -- Notify the supervisor if the status is submitted
    IF @Status = 'Submitted' AND @SupervisorId IS NOT NULL
    BEGIN
        INSERT INTO Notifications (
            UserId,
            Title,
            Message,
            NotificationType,
            RelatedEntityId,
            IsRead,
            CreatedDate
        )
        VALUES (
            @SupervisorId,
            'Change Request Submitted for Review',
            'A change request "' + @Title + '" has been submitted and requires your review.',
            'ChangeRequest',
            @ChangeRequestId,
            0,
            GETDATE()
        );
    END
    
    -- Return the updated change request
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
        supervisor.UserId AS SupervisorId,
        supervisor.FirstName + ' ' + supervisor.LastName AS SupervisorName
    FROM 
        ChangeRequests cr
    INNER JOIN 
        Users requester ON cr.RequesterId = requester.UserId
    LEFT JOIN 
        Users supervisor ON cr.SupervisorId = supervisor.UserId
    WHERE 
        cr.ChangeRequestId = @ChangeRequestId;
END;
GO

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Updates the status of a change request and creates appropriate notifications and review records',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'UpdateChangeRequestStatus';
GO
