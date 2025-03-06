-- CreateChangeRequest stored procedure
CREATE OR ALTER PROCEDURE [dbo].[CreateChangeRequest]
    @Title NVARCHAR(100),
    @Description NVARCHAR(MAX),
    @RequesterId INT,
    @SupervisorId INT = NULL,
    @Priority NVARCHAR(20) = 'Medium',
    @ImpactLevel NVARCHAR(20) = 'Medium',
    @RiskLevel NVARCHAR(20) = 'Medium',
    @ImplementationDate DATETIME = NULL,
    @Status NVARCHAR(50) = 'Draft',
    @ChangeRequestId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate required parameters
    IF @Title IS NULL OR @Description IS NULL OR @RequesterId IS NULL
    BEGIN
        RAISERROR('Title, Description, and RequesterId are required parameters', 16, 1);
        RETURN;
    END
    
    -- Validate that the requester exists
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @RequesterId)
    BEGIN
        RAISERROR('The specified requester does not exist', 16, 1);
        RETURN;
    END
    
    -- Validate that the supervisor exists if provided
    IF @SupervisorId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @SupervisorId)
    BEGIN
        RAISERROR('The specified supervisor does not exist', 16, 1);
        RETURN;
    END
    
    -- Set submission date if status is not Draft
    DECLARE @SubmissionDate DATETIME = NULL;
    IF @Status <> 'Draft'
    BEGIN
        SET @SubmissionDate = GETDATE();
    END
    
    -- Insert the change request
    INSERT INTO ChangeRequests (
        Title,
        Description,
        RequesterId,
        SupervisorId,
        Status,
        Priority,
        ImpactLevel,
        RiskLevel,
        ImplementationDate,
        SubmissionDate,
        CreatedDate,
        LastModifiedDate
    )
    VALUES (
        @Title,
        @Description,
        @RequesterId,
        @SupervisorId,
        @Status,
        @Priority,
        @ImpactLevel,
        @RiskLevel,
        @ImplementationDate,
        @SubmissionDate,
        GETDATE(),
        GETDATE()
    );
    
    -- Get the ID of the newly created change request
    SET @ChangeRequestId = SCOPE_IDENTITY();
    
    -- Create a notification for the supervisor if one is assigned
    IF @SupervisorId IS NOT NULL
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
            'New Change Request Requires Your Review',
            'A new change request "' + @Title + '" has been assigned to you for review.',
            'ChangeRequest',
            @ChangeRequestId,
            0,
            GETDATE()
        );
    END
    
    -- Return the newly created change request
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
    @value = N'Creates a new change request and returns the newly created record',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'CreateChangeRequest';
GO
