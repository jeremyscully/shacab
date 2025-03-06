-- Roles table
CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NOT NULL
);

-- Add index on Role Name for faster lookups
CREATE INDEX IX_Roles_Name ON Roles(Name);

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Stores role definitions for user permissions in the system',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'Roles';

-- Insert default roles
INSERT INTO Roles (Name, Description)
VALUES 
    ('Admin', 'System administrator with full access to all features'),
    ('CABMember', 'Change Advisory Board member who can review and approve change requests'),
    ('Supervisor', 'Department supervisor who can approve change requests from their team'),
    ('User', 'Standard user who can submit change requests');
