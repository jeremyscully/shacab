import { ChangeRequest } from './ChangeRequest';

export interface User {
  userId: number;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  fullName?: string;
  department?: string;
  isActive: boolean;
  createdDate: string;
  lastLoginDate?: string;
  roles?: string;
}

export interface UserDetails {
  userId: number;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  fullName?: string;
  department?: string;
  isActive: boolean;
  createdDate: string;
  lastLoginDate?: string;
  roles: UserRole[];
  supervisors: SupervisorRelationship[];
  supervisees: SupervisorRelationship[];
  recentChangeRequests: ChangeRequest[];
}

export interface UserRole {
  roleId: number;
  roleName: string;
  roleDescription: string;
  assignedDate: string;
}

export interface SupervisorRelationship {
  supervisorId: number;
  department: string;
  assignedDate: string;
  userId: number;
  name: string;
  email: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface CreateUserRequest {
  username: string;
  email: string;
  passwordHash: string;
  firstName: string;
  lastName: string;
  department?: string;
  roleIds?: string;
}

export interface UpdateUserRequest {
  email?: string;
  passwordHash?: string;
  firstName?: string;
  lastName?: string;
  department?: string;
  isActive?: boolean;
}

export interface ManageUserRolesRequest {
  roleIds: string;
  action: 'Add' | 'Remove' | 'Set';
} 