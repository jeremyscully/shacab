import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Box, 
  Typography, 
  Paper, 
  Tabs, 
  Tab, 
  Button, 
  Dialog, 
  DialogTitle, 
  DialogContent, 
  DialogActions, 
  TextField, 
  MenuItem, 
  Grid, 
  Table, 
  TableBody, 
  TableCell, 
  TableContainer, 
  TableHead, 
  TableRow, 
  Chip 
} from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { Calendar, momentLocalizer } from 'react-big-calendar';
import moment from 'moment';
import 'react-big-calendar/lib/css/react-big-calendar.css';
import { useForm, Controller } from 'react-hook-form';
import { useAuth } from '../contexts/AuthContext';
import { changeRequestApi } from '../services/api';
import { 
  ChangeRequest, 
  ChangeRequestStatus, 
  Priority, 
  ImpactLevel, 
  RiskLevel, 
  CreateChangeRequestRequest 
} from '../models/ChangeRequest';

// Setup the localizer for the calendar
const localizer = momentLocalizer(moment);

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

const ProfilePage: React.FC = () => {
  const [view, setView] = useState<'list' | 'calendar'>('list');
  const [changeRequests, setChangeRequests] = useState<ChangeRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [openDialog, setOpenDialog] = useState(false);
  const { user } = useAuth();
  const navigate = useNavigate();
  
  const { control, handleSubmit, reset, formState: { errors } } = useForm<CreateChangeRequestRequest>({
    defaultValues: {
      title: '',
      description: '',
      requesterId: user?.userId || 0,
      priority: 'Medium',
      impactLevel: 'Medium',
      riskLevel: 'Medium',
      status: 'Draft'
    }
  });

  useEffect(() => {
    const fetchChangeRequests = async () => {
      if (!user) return;
      
      try {
        setLoading(true);
        const data = await changeRequestApi.getUserChangeRequests(user.userId);
        setChangeRequests(data);
        setError(null);
      } catch (err) {
        console.error('Failed to fetch change requests:', err);
        setError('Failed to load change requests. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    fetchChangeRequests();
  }, [user]);

  const handleViewChange = (_event: React.SyntheticEvent, newValue: 'list' | 'calendar') => {
    setView(newValue);
  };

  const handleOpenDialog = () => {
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    reset();
  };

  const handleCreateChangeRequest = async (data: CreateChangeRequestRequest) => {
    try {
      if (!user) return;
      
      data.requesterId = user.userId;
      
      await changeRequestApi.create(data);
      
      // Refresh the change requests list
      const updatedRequests = await changeRequestApi.getUserChangeRequests(user.userId);
      setChangeRequests(updatedRequests);
      
      handleCloseDialog();
    } catch (err) {
      console.error('Failed to create change request:', err);
      setError('Failed to create change request. Please try again later.');
    }
  };

  const handleRowClick = (id: number) => {
    navigate(`/change-requests/${id}`);
  };

  const handleEventClick = (event: { id: number }) => {
    navigate(`/change-requests/${event.id}`);
  };

  // Format change requests for calendar view
  const calendarEvents = changeRequests.map(cr => ({
    id: cr.changeRequestId,
    title: cr.title,
    start: cr.implementationDate ? new Date(cr.implementationDate) : new Date(),
    end: cr.implementationDate ? new Date(cr.implementationDate) : new Date(),
    allDay: true,
    status: cr.status.toLowerCase()
  }));

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" component="h1">
          My Change Requests
        </Typography>
        <Button 
          variant="contained" 
          color="primary" 
          onClick={handleOpenDialog}
        >
          Add New Change Request
        </Button>
      </Box>

      <Paper sx={{ mb: 3 }}>
        <Tabs
          value={view}
          onChange={handleViewChange}
          indicatorColor="primary"
          textColor="primary"
          centered
        >
          <Tab label="List View" value="list" />
          <Tab label="Calendar View" value="calendar" />
        </Tabs>
      </Paper>

      {error && (
        <Paper sx={{ p: 2, mb: 3, bgcolor: 'error.light', color: 'error.contrastText' }}>
          <Typography>{error}</Typography>
        </Paper>
      )}

      {loading ? (
        <Typography>Loading change requests...</Typography>
      ) : (
        <>
          {view === 'list' ? (
            <TableContainer component={Paper}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>ID</TableCell>
                    <TableCell>Title</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell>Priority</TableCell>
                    <TableCell>Implementation Date</TableCell>
                    <TableCell>Submission Date</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {changeRequests.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} align="center">
                        No change requests found. Create your first one!
                      </TableCell>
                    </TableRow>
                  ) : (
                    changeRequests.map((cr) => (
                      <TableRow 
                        key={cr.changeRequestId} 
                        hover 
                        onClick={() => handleRowClick(cr.changeRequestId)}
                        sx={{ cursor: 'pointer' }}
                      >
                        <TableCell>{cr.changeRequestId}</TableCell>
                        <TableCell>{cr.title}</TableCell>
                        <TableCell>
                          <Chip 
                            label={cr.status} 
                            color={statusColors[cr.status] as any} 
                            size="small" 
                          />
                        </TableCell>
                        <TableCell>{cr.priority}</TableCell>
                        <TableCell>
                          {cr.implementationDate ? new Date(cr.implementationDate).toLocaleDateString() : 'Not set'}
                        </TableCell>
                        <TableCell>
                          {cr.submissionDate ? new Date(cr.submissionDate).toLocaleDateString() : 'Not submitted'}
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          ) : (
            <Paper sx={{ p: 2, height: 600 }}>
              <Calendar
                localizer={localizer}
                events={calendarEvents}
                startAccessor="start"
                endAccessor="end"
                style={{ height: '100%' }}
                onSelectEvent={handleEventClick}
                eventPropGetter={(event) => ({
                  className: event.status
                })}
              />
            </Paper>
          )}
        </>
      )}

      {/* Create Change Request Dialog */}
      <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>Create New Change Request</DialogTitle>
        <form onSubmit={handleSubmit(handleCreateChangeRequest)}>
          <DialogContent>
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <Controller
                  name="title"
                  control={control}
                  rules={{ required: 'Title is required' }}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Title"
                      fullWidth
                      required
                      error={!!errors.title}
                      helperText={errors.title?.message}
                    />
                  )}
                />
              </Grid>
              <Grid item xs={12}>
                <Controller
                  name="description"
                  control={control}
                  rules={{ required: 'Description is required' }}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Description"
                      fullWidth
                      required
                      multiline
                      rows={4}
                      error={!!errors.description}
                      helperText={errors.description?.message}
                    />
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={4}>
                <Controller
                  name="priority"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      select
                      label="Priority"
                      fullWidth
                    >
                      <MenuItem value="Low">Low</MenuItem>
                      <MenuItem value="Medium">Medium</MenuItem>
                      <MenuItem value="High">High</MenuItem>
                      <MenuItem value="Critical">Critical</MenuItem>
                    </TextField>
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={4}>
                <Controller
                  name="impactLevel"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      select
                      label="Impact Level"
                      fullWidth
                    >
                      <MenuItem value="Low">Low</MenuItem>
                      <MenuItem value="Medium">Medium</MenuItem>
                      <MenuItem value="High">High</MenuItem>
                      <MenuItem value="Critical">Critical</MenuItem>
                    </TextField>
                  )}
                />
              </Grid>
              <Grid item xs={12} sm={4}>
                <Controller
                  name="riskLevel"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      select
                      label="Risk Level"
                      fullWidth
                    >
                      <MenuItem value="Low">Low</MenuItem>
                      <MenuItem value="Medium">Medium</MenuItem>
                      <MenuItem value="High">High</MenuItem>
                      <MenuItem value="Critical">Critical</MenuItem>
                    </TextField>
                  )}
                />
              </Grid>
              <Grid item xs={12}>
                <LocalizationProvider dateAdapter={AdapterDateFns}>
                  <Controller
                    name="implementationDate"
                    control={control}
                    render={({ field }) => (
                      <DatePicker
                        label="Implementation Date"
                        value={field.value ? new Date(field.value) : null}
                        onChange={(date) => field.onChange(date ? date.toISOString() : null)}
                        slotProps={{
                          textField: {
                            fullWidth: true,
                            variant: 'outlined'
                          }
                        }}
                      />
                    )}
                  />
                </LocalizationProvider>
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog}>Cancel</Button>
            <Button type="submit" variant="contained" color="primary">Create</Button>
          </DialogActions>
        </form>
      </Dialog>
    </Box>
  );
};

export default ProfilePage; 