import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { 
  Box, 
  Typography, 
  Paper, 
  Grid, 
  Chip, 
  Button, 
  Divider, 
  List, 
  ListItem, 
  ListItemText, 
  ListItemAvatar, 
  Avatar, 
  Dialog, 
  DialogTitle, 
  DialogContent, 
  DialogActions, 
  TextField, 
  MenuItem 
} from '@mui/material';
import { 
  Description as DescriptionIcon, 
  Person as PersonIcon, 
  CalendarToday as CalendarIcon, 
  Flag as FlagIcon, 
  Warning as WarningIcon, 
  Attachment as AttachmentIcon, 
  Comment as CommentIcon 
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { changeRequestApi } from '../services/api';
import { 
  ChangeRequestDetails, 
  ChangeRequestStatus, 
  UpdateChangeRequestStatusRequest 
} from '../models/ChangeRequest';

// Status chip colors
const statusColors: Record<ChangeRequestStatus, string> = {
  Draft: 'default',
  Submitted: 'warning',
  InReview: 'info',
  Approved: 'success',
  Rejected: 'error',
  Implemented: 'secondary',
  Closed: 'default'
};

const ChangeRequestDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [changeRequest, setChangeRequest] = useState<ChangeRequestDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [openStatusDialog, setOpenStatusDialog] = useState(false);
  const [newStatus, setNewStatus] = useState<ChangeRequestStatus>('Draft');
  const [statusComment, setStatusComment] = useState('');
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const fetchChangeRequestDetails = async () => {
      if (!id) return;
      
      try {
        setLoading(true);
        const data = await changeRequestApi.getById(parseInt(id, 10));
        setChangeRequest(data);
        setError(null);
      } catch (err) {
        console.error('Failed to fetch change request details:', err);
        setError('Failed to load change request details. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    fetchChangeRequestDetails();
  }, [id]);

  const handleOpenStatusDialog = () => {
    if (changeRequest) {
      setNewStatus(changeRequest.status);
    }
    setOpenStatusDialog(true);
  };

  const handleCloseStatusDialog = () => {
    setOpenStatusDialog(false);
    setStatusComment('');
  };

  const handleUpdateStatus = async () => {
    if (!changeRequest || !user) return;
    
    try {
      const request: UpdateChangeRequestStatusRequest = {
        status: newStatus,
        userId: user.userId,
        comments: statusComment
      };
      
      await changeRequestApi.updateStatus(changeRequest.changeRequestId, request);
      
      // Refresh the change request details
      const updatedRequest = await changeRequestApi.getById(changeRequest.changeRequestId);
      setChangeRequest(updatedRequest);
      
      handleCloseStatusDialog();
    } catch (err) {
      console.error('Failed to update change request status:', err);
      setError('Failed to update status. Please try again later.');
    }
  };

  const formatDate = (dateString: string | null) => {
    if (!dateString) return 'Not set';
    return new Date(dateString).toLocaleDateString();
  };

  if (loading) {
    return <Typography>Loading change request details...</Typography>;
  }

  if (error) {
    return (
      <Paper sx={{ p: 3, bgcolor: 'error.light', color: 'error.contrastText' }}>
        <Typography>{error}</Typography>
        <Button 
          variant="contained" 
          color="primary" 
          onClick={() => navigate(-1)} 
          sx={{ mt: 2 }}
        >
          Go Back
        </Button>
      </Paper>
    );
  }

  if (!changeRequest) {
    return (
      <Paper sx={{ p: 3 }}>
        <Typography>Change request not found.</Typography>
        <Button 
          variant="contained" 
          color="primary" 
          onClick={() => navigate(-1)} 
          sx={{ mt: 2 }}
        >
          Go Back
        </Button>
      </Paper>
    );
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" component="h1">
          Change Request #{changeRequest.changeRequestId}
        </Typography>
        <Button 
          variant="contained" 
          color="primary" 
          onClick={() => navigate(-1)}
        >
          Back to List
        </Button>
      </Box>

      <Paper sx={{ p: 3, mb: 3 }}>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <Typography variant="h5" gutterBottom>
              {changeRequest.title}
            </Typography>
            <Chip 
              label={changeRequest.status} 
              color={statusColors[changeRequest.status] as any} 
              sx={{ mr: 1 }}
            />
            <Chip 
              label={`Priority: ${changeRequest.priority}`} 
              variant="outlined" 
              sx={{ mr: 1 }}
            />
            <Chip 
              label={`Impact: ${changeRequest.impactLevel}`} 
              variant="outlined" 
              sx={{ mr: 1 }}
            />
            <Chip 
              label={`Risk: ${changeRequest.riskLevel}`} 
              variant="outlined" 
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
              <PersonIcon sx={{ mr: 1, color: 'primary.main' }} />
              <Typography variant="subtitle1">
                Requester: {changeRequest.requesterName}
              </Typography>
            </Box>
            {changeRequest.supervisorName && (
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <PersonIcon sx={{ mr: 1, color: 'primary.main' }} />
                <Typography variant="subtitle1">
                  Supervisor: {changeRequest.supervisorName}
                </Typography>
              </Box>
            )}
          </Grid>

          <Grid item xs={12} md={6}>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
              <CalendarIcon sx={{ mr: 1, color: 'primary.main' }} />
              <Typography variant="subtitle1">
                Implementation Date: {formatDate(changeRequest.implementationDate)}
              </Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
              <CalendarIcon sx={{ mr: 1, color: 'primary.main' }} />
              <Typography variant="subtitle1">
                Submission Date: {formatDate(changeRequest.submissionDate)}
              </Typography>
            </Box>
          </Grid>

          <Grid item xs={12}>
            <Divider sx={{ my: 2 }} />
            <Typography variant="h6" gutterBottom>
              Description
            </Typography>
            <Typography variant="body1" paragraph>
              {changeRequest.description}
            </Typography>
          </Grid>

          {user && (
            <Grid item xs={12}>
              <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
                <Button 
                  variant="contained" 
                  color="primary" 
                  onClick={handleOpenStatusDialog}
                >
                  Update Status
                </Button>
              </Box>
            </Grid>
          )}
        </Grid>
      </Paper>

      {changeRequest.reviews.length > 0 && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" gutterBottom>
            Reviews
          </Typography>
          <List>
            {changeRequest.reviews.map((review) => (
              <ListItem key={review.reviewId} alignItems="flex-start">
                <ListItemAvatar>
                  <Avatar>
                    <CommentIcon />
                  </Avatar>
                </ListItemAvatar>
                <ListItemText
                  primary={`${review.reviewerName} - ${review.decision}`}
                  secondary={
                    <>
                      <Typography component="span" variant="body2" color="text.primary">
                        {new Date(review.reviewDate).toLocaleString()}
                      </Typography>
                      {review.comments && (
                        <Typography component="p" variant="body2">
                          {review.comments}
                        </Typography>
                      )}
                    </>
                  }
                />
              </ListItem>
            ))}
          </List>
        </Paper>
      )}

      {changeRequest.attachments.length > 0 && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" gutterBottom>
            Attachments
          </Typography>
          <List>
            {changeRequest.attachments.map((attachment) => (
              <ListItem key={attachment.attachmentId} alignItems="flex-start">
                <ListItemAvatar>
                  <Avatar>
                    <AttachmentIcon />
                  </Avatar>
                </ListItemAvatar>
                <ListItemText
                  primary={attachment.fileName}
                  secondary={
                    <>
                      <Typography component="span" variant="body2" color="text.primary">
                        {`Uploaded by ${attachment.uploaderName} on ${new Date(attachment.uploadDate).toLocaleString()}`}
                      </Typography>
                      {attachment.description && (
                        <Typography component="p" variant="body2">
                          {attachment.description}
                        </Typography>
                      )}
                    </>
                  }
                />
              </ListItem>
            ))}
          </List>
        </Paper>
      )}

      {/* Update Status Dialog */}
      <Dialog open={openStatusDialog} onClose={handleCloseStatusDialog}>
        <DialogTitle>Update Change Request Status</DialogTitle>
        <DialogContent>
          <TextField
            select
            label="Status"
            value={newStatus}
            onChange={(e) => setNewStatus(e.target.value as ChangeRequestStatus)}
            fullWidth
            margin="normal"
          >
            <MenuItem value="Draft">Draft</MenuItem>
            <MenuItem value="Submitted">Submitted</MenuItem>
            <MenuItem value="InReview">In Review</MenuItem>
            <MenuItem value="Approved">Approved</MenuItem>
            <MenuItem value="Rejected">Rejected</MenuItem>
            <MenuItem value="Implemented">Implemented</MenuItem>
            <MenuItem value="Closed">Closed</MenuItem>
          </TextField>
          <TextField
            label="Comments"
            value={statusComment}
            onChange={(e) => setStatusComment(e.target.value)}
            fullWidth
            multiline
            rows={4}
            margin="normal"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseStatusDialog}>Cancel</Button>
          <Button onClick={handleUpdateStatus} variant="contained" color="primary">
            Update
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ChangeRequestDetailsPage; 