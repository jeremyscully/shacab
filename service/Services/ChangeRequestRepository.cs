using System.Data;
using ShacabService.Models;

namespace ShacabService.Services;

public interface IChangeRequestRepository
{
    Task<IEnumerable<ChangeRequestSummary>> GetChangeRequestsByStatusAsync(string? status);
    Task<ChangeRequestDetails?> GetChangeRequestDetailsAsync(int changeRequestId);
    Task<int> CreateChangeRequestAsync(string title, string description, int requesterId, int? supervisorId, string? priority, string? impactLevel, string? riskLevel, DateTime? implementationDate, string? status);
    Task<ChangeRequestSummary?> UpdateChangeRequestStatusAsync(int changeRequestId, string status, int userId, string? comments);
    Task<IEnumerable<ChangeRequestSummary>> GetUserChangeRequestsAsync(int userId, string? status);
}

public class ChangeRequestRepository : IChangeRequestRepository
{
    private readonly IDatabaseService _db;

    public ChangeRequestRepository(IDatabaseService db)
    {
        _db = db;
    }

    public async Task<IEnumerable<ChangeRequestSummary>> GetChangeRequestsByStatusAsync(string? status)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@Status", status }
        };

        return await _db.QueryAsync<ChangeRequestSummary>(
            "GetChangeRequestsByStatus",
            parameters,
            reader => new ChangeRequestSummary
            {
                ChangeRequestId = reader.GetInt32(reader.GetOrdinal("ChangeRequestId")),
                Title = reader.GetString(reader.GetOrdinal("Title")),
                Description = reader.GetString(reader.GetOrdinal("Description")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                Priority = reader.GetString(reader.GetOrdinal("Priority")),
                ImpactLevel = reader.GetString(reader.GetOrdinal("ImpactLevel")),
                RiskLevel = reader.GetString(reader.GetOrdinal("RiskLevel")),
                ImplementationDate = reader.IsDBNull(reader.GetOrdinal("ImplementationDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ImplementationDate")),
                SubmissionDate = reader.IsDBNull(reader.GetOrdinal("SubmissionDate")) ? null : reader.GetDateTime(reader.GetOrdinal("SubmissionDate")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                LastModifiedDate = reader.GetDateTime(reader.GetOrdinal("LastModifiedDate")),
                RequesterId = reader.GetInt32(reader.GetOrdinal("RequesterId")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                SupervisorId = reader.IsDBNull(reader.GetOrdinal("SupervisorId")) ? null : reader.GetInt32(reader.GetOrdinal("SupervisorId")),
                SupervisorName = reader.IsDBNull(reader.GetOrdinal("SupervisorName")) ? null : reader.GetString(reader.GetOrdinal("SupervisorName"))
            });
    }

    public async Task<ChangeRequestDetails?> GetChangeRequestDetailsAsync(int changeRequestId)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@ChangeRequestId", changeRequestId }
        };

        var result = await _db.QueryMultipleAsync<ChangeRequestDetails, ReviewInfo, AttachmentInfo, SupportAssignmentInfo, MeetingInfo>(
            "GetChangeRequestDetails",
            parameters,
            // Change request details mapper
            reader => new ChangeRequestDetails
            {
                ChangeRequestId = reader.GetInt32(reader.GetOrdinal("ChangeRequestId")),
                Title = reader.GetString(reader.GetOrdinal("Title")),
                Description = reader.GetString(reader.GetOrdinal("Description")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                Priority = reader.GetString(reader.GetOrdinal("Priority")),
                ImpactLevel = reader.GetString(reader.GetOrdinal("ImpactLevel")),
                RiskLevel = reader.GetString(reader.GetOrdinal("RiskLevel")),
                ImplementationDate = reader.IsDBNull(reader.GetOrdinal("ImplementationDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ImplementationDate")),
                SubmissionDate = reader.IsDBNull(reader.GetOrdinal("SubmissionDate")) ? null : reader.GetDateTime(reader.GetOrdinal("SubmissionDate")),
                ApprovalDate = reader.IsDBNull(reader.GetOrdinal("ApprovalDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ApprovalDate")),
                ClosureDate = reader.IsDBNull(reader.GetOrdinal("ClosureDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ClosureDate")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                LastModifiedDate = reader.GetDateTime(reader.GetOrdinal("LastModifiedDate")),
                RequesterId = reader.GetInt32(reader.GetOrdinal("RequesterId")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                RequesterEmail = reader.GetString(reader.GetOrdinal("RequesterEmail")),
                SupervisorId = reader.IsDBNull(reader.GetOrdinal("SupervisorId")) ? null : reader.GetInt32(reader.GetOrdinal("SupervisorId")),
                SupervisorName = reader.IsDBNull(reader.GetOrdinal("SupervisorName")) ? null : reader.GetString(reader.GetOrdinal("SupervisorName")),
                SupervisorEmail = reader.IsDBNull(reader.GetOrdinal("SupervisorEmail")) ? null : reader.GetString(reader.GetOrdinal("SupervisorEmail"))
            },
            // Reviews mapper
            reader => new ReviewInfo
            {
                ReviewId = reader.GetInt32(reader.GetOrdinal("ReviewId")),
                ChangeRequestId = reader.GetInt32(reader.GetOrdinal("ChangeRequestId")),
                ReviewerId = reader.GetInt32(reader.GetOrdinal("ReviewerId")),
                ReviewerName = reader.GetString(reader.GetOrdinal("ReviewerName")),
                ReviewerEmail = reader.GetString(reader.GetOrdinal("ReviewerEmail")),
                Decision = reader.GetString(reader.GetOrdinal("Decision")),
                Comments = reader.IsDBNull(reader.GetOrdinal("Comments")) ? null : reader.GetString(reader.GetOrdinal("Comments")),
                ReviewDate = reader.GetDateTime(reader.GetOrdinal("ReviewDate"))
            },
            // Attachments mapper
            reader => new AttachmentInfo
            {
                AttachmentId = reader.GetInt32(reader.GetOrdinal("AttachmentId")),
                ChangeRequestId = reader.GetInt32(reader.GetOrdinal("ChangeRequestId")),
                FileName = reader.GetString(reader.GetOrdinal("FileName")),
                FileType = reader.GetString(reader.GetOrdinal("FileType")),
                FileSize = reader.GetInt32(reader.GetOrdinal("FileSize")),
                UploadedBy = reader.GetInt32(reader.GetOrdinal("UploadedBy")),
                UploaderName = reader.GetString(reader.GetOrdinal("UploaderName")),
                UploadDate = reader.GetDateTime(reader.GetOrdinal("UploadDate")),
                Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description"))
            },
            // Support assignments mapper
            reader => new SupportAssignmentInfo
            {
                AssignmentId = reader.GetInt32(reader.GetOrdinal("AssignmentId")),
                ChangeRequestId = reader.GetInt32(reader.GetOrdinal("ChangeRequestId")),
                AssignedToId = reader.GetInt32(reader.GetOrdinal("AssignedToId")),
                AssigneeName = reader.GetString(reader.GetOrdinal("AssigneeName")),
                AssigneeEmail = reader.GetString(reader.GetOrdinal("AssigneeEmail")),
                AssignedById = reader.GetInt32(reader.GetOrdinal("AssignedById")),
                AssignerName = reader.GetString(reader.GetOrdinal("AssignerName")),
                AssignmentDate = reader.GetDateTime(reader.GetOrdinal("AssignmentDate")),
                DueDate = reader.IsDBNull(reader.GetOrdinal("DueDate")) ? null : reader.GetDateTime(reader.GetOrdinal("DueDate")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? null : reader.GetString(reader.GetOrdinal("Notes")),
                CompletionDate = reader.IsDBNull(reader.GetOrdinal("CompletionDate")) ? null : reader.GetDateTime(reader.GetOrdinal("CompletionDate"))
            },
            // Meetings mapper
            reader => new MeetingInfo
            {
                MeetingId = reader.GetInt32(reader.GetOrdinal("MeetingId")),
                MeetingTitle = reader.GetString(reader.GetOrdinal("MeetingTitle")),
                ScheduledDate = reader.GetDateTime(reader.GetOrdinal("ScheduledDate")),
                MeetingStatus = reader.GetString(reader.GetOrdinal("MeetingStatus")),
                DiscussionOrder = reader.IsDBNull(reader.GetOrdinal("DiscussionOrder")) ? null : reader.GetInt32(reader.GetOrdinal("DiscussionOrder")),
                DiscussionDuration = reader.IsDBNull(reader.GetOrdinal("DiscussionDuration")) ? null : reader.GetInt32(reader.GetOrdinal("DiscussionDuration")),
                Decision = reader.IsDBNull(reader.GetOrdinal("Decision")) ? null : reader.GetString(reader.GetOrdinal("Decision")),
                DecisionNotes = reader.IsDBNull(reader.GetOrdinal("DecisionNotes")) ? null : reader.GetString(reader.GetOrdinal("DecisionNotes")),
                DiscussionNotes = reader.IsDBNull(reader.GetOrdinal("DiscussionNotes")) ? null : reader.GetString(reader.GetOrdinal("DiscussionNotes"))
            });

        var changeRequestDetails = result.Item1.FirstOrDefault();
        if (changeRequestDetails == null)
            return null;

        changeRequestDetails.Reviews = result.Item2.ToList();
        changeRequestDetails.Attachments = result.Item3.ToList();
        changeRequestDetails.SupportAssignments = result.Item4.ToList();
        changeRequestDetails.Meetings = result.Item5.ToList();

        return changeRequestDetails;
    }

    public async Task<int> CreateChangeRequestAsync(string title, string description, int requesterId, int? supervisorId, string? priority, string? impactLevel, string? riskLevel, DateTime? implementationDate, string? status)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@Title", title },
            { "@Description", description },
            { "@RequesterId", requesterId },
            { "@SupervisorId", supervisorId },
            { "@Priority", priority ?? "Medium" },
            { "@ImpactLevel", impactLevel ?? "Medium" },
            { "@RiskLevel", riskLevel ?? "Medium" },
            { "@ImplementationDate", implementationDate },
            { "@Status", status ?? "Draft" },
            { "@ChangeRequestIdOutput", null }
        };

        // Execute the stored procedure
        await _db.ExecuteNonQueryAsync("CreateChangeRequest", parameters);

        // Get the output parameter value
        using var connection = await _db.CreateConnectionAsync();
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT @ChangeRequestIdOutput";
        command.Parameters.AddWithValue("@ChangeRequestIdOutput", parameters["@ChangeRequestIdOutput"]);
        var changeRequestId = (int)await command.ExecuteScalarAsync();

        return changeRequestId;
    }

    public async Task<ChangeRequestSummary?> UpdateChangeRequestStatusAsync(int changeRequestId, string status, int userId, string? comments)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@ChangeRequestId", changeRequestId },
            { "@Status", status },
            { "@UserId", userId },
            { "@Comments", comments }
        };

        var result = await _db.QueryAsync<ChangeRequestSummary>(
            "UpdateChangeRequestStatus",
            parameters,
            reader => new ChangeRequestSummary
            {
                ChangeRequestId = reader.GetInt32(reader.GetOrdinal("ChangeRequestId")),
                Title = reader.GetString(reader.GetOrdinal("Title")),
                Description = reader.GetString(reader.GetOrdinal("Description")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                Priority = reader.GetString(reader.GetOrdinal("Priority")),
                ImpactLevel = reader.GetString(reader.GetOrdinal("ImpactLevel")),
                RiskLevel = reader.GetString(reader.GetOrdinal("RiskLevel")),
                ImplementationDate = reader.IsDBNull(reader.GetOrdinal("ImplementationDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ImplementationDate")),
                SubmissionDate = reader.IsDBNull(reader.GetOrdinal("SubmissionDate")) ? null : reader.GetDateTime(reader.GetOrdinal("SubmissionDate")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                LastModifiedDate = reader.GetDateTime(reader.GetOrdinal("LastModifiedDate")),
                RequesterId = reader.GetInt32(reader.GetOrdinal("RequesterId")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                SupervisorId = reader.IsDBNull(reader.GetOrdinal("SupervisorId")) ? null : reader.GetInt32(reader.GetOrdinal("SupervisorId")),
                SupervisorName = reader.IsDBNull(reader.GetOrdinal("SupervisorName")) ? null : reader.GetString(reader.GetOrdinal("SupervisorName"))
            });

        return result.FirstOrDefault();
    }

    public async Task<IEnumerable<ChangeRequestSummary>> GetUserChangeRequestsAsync(int userId, string? status)
    {
        var parameters = new Dictionary<string, object?>
        {
            { "@UserId", userId },
            { "@Status", status }
        };

        return await _db.QueryAsync<ChangeRequestSummary>(
            "GetUserChangeRequests",
            parameters,
            reader => new ChangeRequestSummary
            {
                ChangeRequestId = reader.GetInt32(reader.GetOrdinal("ChangeRequestId")),
                Title = reader.GetString(reader.GetOrdinal("Title")),
                Description = reader.GetString(reader.GetOrdinal("Description")),
                Status = reader.GetString(reader.GetOrdinal("Status")),
                Priority = reader.GetString(reader.GetOrdinal("Priority")),
                ImpactLevel = reader.GetString(reader.GetOrdinal("ImpactLevel")),
                RiskLevel = reader.GetString(reader.GetOrdinal("RiskLevel")),
                ImplementationDate = reader.IsDBNull(reader.GetOrdinal("ImplementationDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ImplementationDate")),
                SubmissionDate = reader.IsDBNull(reader.GetOrdinal("SubmissionDate")) ? null : reader.GetDateTime(reader.GetOrdinal("SubmissionDate")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                LastModifiedDate = reader.GetDateTime(reader.GetOrdinal("LastModifiedDate")),
                RequesterId = reader.GetInt32(reader.GetOrdinal("RequesterId")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                SupervisorId = reader.IsDBNull(reader.GetOrdinal("SupervisorId")) ? null : reader.GetInt32(reader.GetOrdinal("SupervisorId")),
                SupervisorName = reader.IsDBNull(reader.GetOrdinal("SupervisorName")) ? null : reader.GetString(reader.GetOrdinal("SupervisorName")),
                AccessType = reader.GetString(reader.GetOrdinal("AccessType"))
            });
    }
} 