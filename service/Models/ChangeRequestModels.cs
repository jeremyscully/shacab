namespace ShacabService.Models;

// Request models
public class CreateChangeRequestRequest
{
    public required string Title { get; set; }
    public required string Description { get; set; }
    public required int RequesterId { get; set; }
    public int? SupervisorId { get; set; }
    public string? Priority { get; set; } = "Medium";
    public string? ImpactLevel { get; set; } = "Medium";
    public string? RiskLevel { get; set; } = "Medium";
    public DateTime? ImplementationDate { get; set; }
    public string? Status { get; set; } = "Draft";
}

public class UpdateChangeRequestStatusRequest
{
    public required string Status { get; set; }
    public required int UserId { get; set; }
    public string? Comments { get; set; }
}

// Response models
public class ChangeRequestSummary
{
    public int ChangeRequestId { get; set; }
    public required string Title { get; set; }
    public required string Description { get; set; }
    public required string Status { get; set; }
    public required string Priority { get; set; }
    public required string ImpactLevel { get; set; }
    public required string RiskLevel { get; set; }
    public DateTime? ImplementationDate { get; set; }
    public DateTime? SubmissionDate { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime LastModifiedDate { get; set; }
    public int RequesterId { get; set; }
    public required string RequesterName { get; set; }
    public int? SupervisorId { get; set; }
    public string? SupervisorName { get; set; }
    public string? AccessType { get; set; }
}

public class ChangeRequestDetails
{
    public int ChangeRequestId { get; set; }
    public required string Title { get; set; }
    public required string Description { get; set; }
    public required string Status { get; set; }
    public required string Priority { get; set; }
    public required string ImpactLevel { get; set; }
    public required string RiskLevel { get; set; }
    public DateTime? ImplementationDate { get; set; }
    public DateTime? SubmissionDate { get; set; }
    public DateTime? ApprovalDate { get; set; }
    public DateTime? ClosureDate { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime LastModifiedDate { get; set; }
    public int RequesterId { get; set; }
    public required string RequesterName { get; set; }
    public required string RequesterEmail { get; set; }
    public int? SupervisorId { get; set; }
    public string? SupervisorName { get; set; }
    public string? SupervisorEmail { get; set; }
    public List<ReviewInfo> Reviews { get; set; } = new();
    public List<AttachmentInfo> Attachments { get; set; } = new();
    public List<SupportAssignmentInfo> SupportAssignments { get; set; } = new();
    public List<MeetingInfo> Meetings { get; set; } = new();
}

public class ReviewInfo
{
    public int ReviewId { get; set; }
    public int ChangeRequestId { get; set; }
    public int ReviewerId { get; set; }
    public required string ReviewerName { get; set; }
    public required string ReviewerEmail { get; set; }
    public required string Decision { get; set; }
    public string? Comments { get; set; }
    public DateTime ReviewDate { get; set; }
}

public class AttachmentInfo
{
    public int AttachmentId { get; set; }
    public int ChangeRequestId { get; set; }
    public required string FileName { get; set; }
    public required string FileType { get; set; }
    public int FileSize { get; set; }
    public int UploadedBy { get; set; }
    public required string UploaderName { get; set; }
    public DateTime UploadDate { get; set; }
    public string? Description { get; set; }
}

public class SupportAssignmentInfo
{
    public int AssignmentId { get; set; }
    public int ChangeRequestId { get; set; }
    public int AssignedToId { get; set; }
    public required string AssigneeName { get; set; }
    public required string AssigneeEmail { get; set; }
    public int AssignedById { get; set; }
    public required string AssignerName { get; set; }
    public DateTime AssignmentDate { get; set; }
    public DateTime? DueDate { get; set; }
    public required string Status { get; set; }
    public string? Notes { get; set; }
    public DateTime? CompletionDate { get; set; }
}

public class MeetingInfo
{
    public int MeetingId { get; set; }
    public required string MeetingTitle { get; set; }
    public DateTime ScheduledDate { get; set; }
    public required string MeetingStatus { get; set; }
    public int? DiscussionOrder { get; set; }
    public int? DiscussionDuration { get; set; }
    public string? Decision { get; set; }
    public string? DecisionNotes { get; set; }
    public string? DiscussionNotes { get; set; }
} 