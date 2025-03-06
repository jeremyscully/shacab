-- Users table
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(128) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Department NVARCHAR(50) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastLoginDate DATETIME NULL
);

-- Add index on Username for faster lookups
CREATE INDEX IX_Users_Username ON Users(Username);

-- Add index on Email for faster lookups
CREATE INDEX IX_Users_Email ON Users(Email);

-- Add comments
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Stores user account information for the Change Advisory Board system',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'Users';
