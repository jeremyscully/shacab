-- GetChangeRequestsByStatus stored procedure
CREATE OR ALTER PROCEDURE [dbo].[GetChangeRequestsByStatus]
    @Status NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If status is NULL, return all change requests
    IF @Status IS NULL
    BEGIN
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
        ORDER BY 
            CASE 
                WHEN cr.Status = 'Draft' THEN 1
                WHEN cr.Status = 'Submitted' THEN 2
                WHEN cr.Status = 'InReview' THEN 3
                WHEN cr.Status = 'Approved' THEN 4
                WHEN cr.Status = 'Rejected' THEN 5
                WHEN cr.Status = 'Implemented' THEN 6
                WHEN cr.Status = 'Closed' THEN 7
                ELSE 8
            END,
            cr.Priority DESC,
            cr.ImplementationDate ASC;
    END
    ELSE
    BEGIN
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
            cr.Status = @Status
        ORDER BY 
            cr.Priority DESC,
            cr.ImplementationDate ASC;
    END
END;
GO

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Retrieves change requests filtered by status',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'PROCEDURE',  @level1name = 'GetChangeRequestsByStatus';
GO
