# Workshop Self-Service Portal Setup Guide

This guide explains how to set up and use the Workshop Self-Service Portal in your TIBCO Developer Hub.

## Overview

The Workshop Self-Service Portal allows you to automatically set up workshop environments by:
- Creating user accounts on workshop servers
- Installing required tools and software
- Setting up Docker environments
- Creating shared folders for workshop materials
- Running custom setup scripts

## Architecture

The system consists of:

1. **Custom SSH Scaffolder Action** (`workshop:execute-ssh-script`)
2. **Workshop Template** (`workshop-self-service`)
3. **Server Scripts** (that you need to deploy on your workshop servers)

## Prerequisites

### On the TIBCO Developer Hub side:
1. The custom scaffolder module must be installed (see installation steps)
2. SSH connectivity to workshop servers
3. Appropriate permissions in your Developer Hub

### On the workshop server side:
1. SSH access with sudo privileges
2. Scripts deployed in `/opt/scripts/` directory
3. Proper script permissions (`chmod +x`)

## Installation Steps

### 1. Install Dependencies

Add the `node-ssh` package to your backend:

```bash
cd packages/backend
yarn add node-ssh
```

### 2. Build the Custom Module

```bash
cd plugins/scaffolder-backend-module-workshop-tools
yarn install
yarn build
```

### 3. Restart the Backend

```bash
# In the main project directory
yarn dev  # or your usual start command
```

### 4. Deploy Server Scripts

Copy the example scripts from `server-scripts-examples/` to your workshop server:

```bash
# On your workshop server
sudo mkdir -p /opt/scripts
sudo cp server-scripts-examples/*.sh /opt/scripts/
sudo chmod +x /opt/scripts/*.sh
```

## Server Script Requirements

Your server scripts should:

1. **Accept environment variables** instead of command-line arguments
2. **Use consistent variable names** as shown in the template
3. **Include proper error handling** (`set -e`)
4. **Log operations** for debugging
5. **Be idempotent** (safe to run multiple times)

### Environment Variables Available

The SSH action passes these variables to your scripts:

- `WORKSHOP_NAME` - Name of the workshop
- `USER_COUNT` - Number of participants
- `USER_PREFIX` - Prefix for usernames (e.g., "workshop")
- `DEFAULT_PASSWORD` - Default password for created users
- `USER_SHELL` - Default shell for users
- `CUSTOM_ARGS` - Any custom arguments

### Example Script Structure

```bash
#!/bin/bash
set -e

# Get environment variables with defaults
USER_COUNT=${USER_COUNT:-10}
USER_PREFIX=${USER_PREFIX:-workshop}
# ... more variables

echo "Starting workshop setup..."

# Your setup logic here
# ...

echo "Setup completed successfully!"
```

## Using the Self-Service Portal

### 1. Access the Template

1. Go to your TIBCO Developer Hub
2. Navigate to "Create Component"
3. Find "Workshop Self-Service Portal" template
4. Click "Choose"

### 2. Fill in Workshop Information

- **Workshop Name**: Descriptive name for your workshop
- **Workshop Date**: When the workshop will be held  
- **Participant Count**: Number of expected participants
- **Description**: Brief description of the workshop

### 3. Configure Server Access

- **Server Host**: IP address or hostname of your workshop server
- **Server Username**: SSH username (must have sudo privileges)
- **Server Password**: SSH password (stored securely)
- **Default User Password**: Password for created workshop users

### 4. Configure User Management

- **User Prefix**: Prefix for created usernames (default: "workshop")
- **Create Workshop Users**: Whether to create user accounts
- **User Shell**: Default shell for created users

### 5. Select Additional Activities

- **Setup Docker Environment**: Install and configure Docker
- **Install Workshop Tools**: Install development tools
- **Create Shared Folder**: Create shared workspace
- **Custom Script Path**: Path to your own setup script

### 6. Execute the Workflow

Click "Create" to start the workshop setup process. The system will:

1. Connect to your workshop server via SSH
2. Execute the selected scripts with your parameters
3. Provide a summary of what was created
4. Give you next steps for workshop preparation

## Security Considerations

### SSH Credentials

- **Development**: You can use passwords for testing
- **Production**: Use SSH keys instead of passwords:

```yaml
# In your template, use privateKey instead of password
privateKey: ${{ secrets.SSH_PRIVATE_KEY }}
```

### Server Access

- Use dedicated service accounts for workshop setup
- Limit sudo privileges to only required commands
- Consider using SSH key authentication
- Audit script executions

### User Passwords

- Use strong default passwords
- Force password changes on first login
- Consider using temporary passwords that expire

## Customization

### Adding New Activities

1. Create new server scripts in `/opt/scripts/`
2. Add new parameters to the template
3. Add new steps to execute your scripts

### Custom Parameters

Add new input fields to the template:

```yaml
parameters:
  - title: Custom Configuration
    properties:
      myCustomField:
        title: My Custom Field
        type: string
        description: Description of the field
```

### Integration with Other Systems

You can extend the template to integrate with:

- LDAP/Active Directory for user creation
- Cloud platforms for infrastructure provisioning
- Monitoring systems for workshop tracking
- Email systems for participant notifications

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Verify server host and credentials
   - Check network connectivity
   - Ensure SSH service is running on server

2. **Script Execution Failed**
   - Check script permissions (`chmod +x`)
   - Verify script paths are correct
   - Look at script logs for specific errors

3. **Permission Denied**
   - Ensure SSH user has sudo privileges
   - Check script file ownership
   - Verify directory permissions

### Debugging

1. **Check Backstage Logs**
   ```bash
   # Look for SSH action logs
   yarn dev --verbose
   ```

2. **Test SSH Connection Manually**
   ```bash
   ssh username@server-host
   sudo /opt/tibco/scripts/create-workshop-users.sh
   ```

3. **Validate Script Variables**
   Add debug output to your scripts:
   ```bash
   echo "USER_COUNT=$USER_COUNT"
   echo "USER_PREFIX=$USER_PREFIX"
   ```

## Example Workshop Flow

1. **Pre-Workshop** (1 week before):
   - Run the self-service template
   - Test user accounts and tools
   - Prepare workshop materials

2. **Workshop Day**:
   - Distribute login credentials
   - Verify all participants can access the server
   - Start the workshop activities

3. **Post-Workshop**:
   - Backup participant work
   - Clean up temporary accounts (optional)
   - Gather feedback

## Support and Contributing

For issues or enhancements:
1. Check the troubleshooting section
2. Review server script logs
3. Contact your TIBCO Developer Hub administrator

The system is designed to be extensible - you can add new scripts, parameters, and integrations based on your workshop requirements.