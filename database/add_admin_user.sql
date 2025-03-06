-- add_admin_user.sql
-- Script to add an admin user to the shacab database

-- Check if the admin user already exists
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'admin')
BEGIN
    -- Insert the admin user
    -- Using a simple password hash for demonstration - in production, use proper password hashing
    INSERT INTO Users (
        Username,
        Email,
        PasswordHash,
        FirstName,
        LastName,
        Department,
        IsActive,
        CreatedDate
    )
    VALUES (
        'admin',
        'admin@shacab.com',
        -- This is a simple hash for 'Admin123!' - in a real system, use proper password hashing
        'AQAAAAEAACcQAAAAEJGUgKWXgWnORCh8iKFvA6JIeexlLbBbKtAee8Ceq+XxzxVvdwIVdiSZYf7TV8fQ4A==',
        'System',
        'Administrator',
        'IT',
        1, -- IsActive = true
        GETDATE() -- Current date/time
    );

    -- Get the newly inserted user ID
    DECLARE @AdminUserId INT;
    SELECT @AdminUserId = UserId FROM Users WHERE Username = 'admin';

    -- Assign the Admin role to the user
    INSERT INTO UserRoles (UserId, RoleId, AssignedDate)
    VALUES (@AdminUserId, 1, GETDATE()); -- Role ID 1 is Admin

    PRINT 'Admin user created successfully.';
END
ELSE
BEGIN
    PRINT 'Admin user already exists.';
END 