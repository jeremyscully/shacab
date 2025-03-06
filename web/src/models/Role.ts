export interface Role {
  roleId: number;
  name: string;
  description: string;
}

export interface CreateRoleRequest {
  name: string;
  description: string;
} 