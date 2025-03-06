import axios from 'axios';
import { 
  ChangeRequest, 
  ChangeRequestDetails, 
  CreateChangeRequestRequest, 
  UpdateChangeRequestStatusRequest 
} from '../models/ChangeRequest';
import { 
  User, 
  UserDetails, 
  LoginRequest, 
  LoginResponse, 
  CreateUserRequest, 
  UpdateUserRequest, 
  ManageUserRolesRequest, 
  UserRole 
} from '../models/User';
import { Role, CreateRoleRequest } from '../models/Role';

// Create axios instance
const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Change Request API
export const changeRequestApi = {
  getByStatus: async (status?: string): Promise<ChangeRequest[]> => {
    const response = await api.get<ChangeRequest[]>('/change-requests', {
      params: { status },
    });
    return response.data;
  },
  
  getById: async (id: number): Promise<ChangeRequestDetails> => {
    const response = await api.get<ChangeRequestDetails>(`/change-requests/${id}`);
    return response.data;
  },
  
  create: async (request: CreateChangeRequestRequest): Promise<ChangeRequestDetails> => {
    const response = await api.post<ChangeRequestDetails>('/change-requests', request);
    return response.data;
  },
  
  updateStatus: async (id: number, request: UpdateChangeRequestStatusRequest): Promise<ChangeRequest> => {
    const response = await api.put<ChangeRequest>(`/change-requests/${id}/status`, request);
    return response.data;
  },
  
  getUserChangeRequests: async (userId: number, status?: string): Promise<ChangeRequest[]> => {
    const response = await api.get<ChangeRequest[]>(`/change-requests/user/${userId}`, {
      params: { status },
    });
    return response.data;
  },
};

// User API
export const userApi = {
  login: async (request: LoginRequest): Promise<LoginResponse> => {
    const response = await api.post<LoginResponse>('/auth/login', request);
    return response.data;
  },
  
  getAllUsers: async (
    includeInactive: boolean = false,
    searchTerm?: string,
    department?: string,
    roleId?: number
  ): Promise<User[]> => {
    const response = await api.get<User[]>('/users', {
      params: { includeInactive, searchTerm, department, roleId },
    });
    return response.data;
  },
  
  getUserById: async (id: number): Promise<UserDetails> => {
    const response = await api.get<UserDetails>(`/users/${id}`);
    return response.data;
  },
  
  getUserByUsername: async (username: string): Promise<UserDetails> => {
    const response = await api.get<UserDetails>(`/users/by-username/${username}`);
    return response.data;
  },
  
  createUser: async (request: CreateUserRequest): Promise<UserDetails> => {
    const response = await api.post<UserDetails>('/users', request);
    return response.data;
  },
  
  updateUser: async (id: number, request: UpdateUserRequest): Promise<User> => {
    const response = await api.put<User>(`/users/${id}`, request);
    return response.data;
  },
  
  manageUserRoles: async (id: number, request: ManageUserRolesRequest): Promise<UserRole[]> => {
    const response = await api.put<UserRole[]>(`/users/${id}/roles`, request);
    return response.data;
  },
};

// Role API
export const roleApi = {
  getAllRoles: async (): Promise<Role[]> => {
    const response = await api.get<Role[]>('/roles');
    return response.data;
  },
  
  getRoleById: async (id: number): Promise<Role> => {
    const response = await api.get<Role>(`/roles/${id}`);
    return response.data;
  },
  
  createRole: async (request: CreateRoleRequest): Promise<Role> => {
    const response = await api.post<Role>('/roles', request);
    return response.data;
  },
};

export default api; 