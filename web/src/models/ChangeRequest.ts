export interface ChangeRequest {
  changeRequestId: number;
  title: string;
  description: string;
  status: ChangeRequestStatus;
  priority: Priority;
  impactLevel: ImpactLevel;
  riskLevel: RiskLevel;
  implementationDate: string | null;
  submissionDate: string | null;
  approvalDate: string | null;
  closureDate: string | null;
  createdDate: string;
  lastModifiedDate: string;
  requesterId: number;
  requesterName: string;
  requesterEmail?: string;
  supervisorId?: number | null;
  supervisorName?: string | null;
  supervisorEmail?: string | null;
  accessType?: string;
}

export interface ChangeRequestDetails extends ChangeRequest {
  reviews: Review[];
  attachments: Attachment[];
  supportAssignments: SupportAssignment[];
  meetings: Meeting[];
}

export interface Review {
  reviewId: number;
  changeRequestId: number;
  reviewerId: number;
  reviewerName: string;
  reviewerEmail: string;
  decision: string;
  comments?: string;
  reviewDate: string;
}

export interface Attachment {
  attachmentId: number;
  changeRequestId: number;
  fileName: string;
  fileType: string;
  fileSize: number;
  uploadedBy: number;
  uploaderName: string;
  uploadDate: string;
  description?: string;
}

export interface SupportAssignment {
  assignmentId: number;
  changeRequestId: number;
  assignedToId: number;
  assigneeName: string;
  assigneeEmail: string;
  assignedById: number;
  assignerName: string;
  assignmentDate: string;
  dueDate?: string;
  status: string;
  notes?: string;
  completionDate?: string;
}

export interface Meeting {
  meetingId: number;
  meetingTitle: string;
  scheduledDate: string;
  meetingStatus: string;
  discussionOrder?: number;
  discussionDuration?: number;
  decision?: string;
  decisionNotes?: string;
  discussionNotes?: string;
}

export type ChangeRequestStatus = 
  | 'Draft'
  | 'Submitted'
  | 'InReview'
  | 'Approved'
  | 'Rejected'
  | 'Implemented'
  | 'Closed';

export type Priority = 'Low' | 'Medium' | 'High' | 'Critical';
export type ImpactLevel = 'Low' | 'Medium' | 'High' | 'Critical';
export type RiskLevel = 'Low' | 'Medium' | 'High' | 'Critical';

export interface CreateChangeRequestRequest {
  title: string;
  description: string;
  requesterId: number;
  supervisorId?: number;
  priority?: string;
  impactLevel?: string;
  riskLevel?: string;
  implementationDate?: string;
  status?: string;
}

export interface UpdateChangeRequestStatusRequest {
  status: ChangeRequestStatus;
  userId: number;
  comments?: string;
} 