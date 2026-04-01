/*
 * Copyright (c) 2023-2025. Cloud Software Group, Inc. All Rights Reserved. Confidential & Proprietary
 */

import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import { NodeSSH } from 'node-ssh';

export function createSshExecutionAction() {
  return createTemplateAction({
    id: 'workshop:execute-ssh-script',
    description: 'Execute a script on a remote server via SSH',
    examples: [
      {
        description: 'Execute user creation script with parameters',
        example: `
steps:
  - action: workshop:execute-ssh-script
    id: create-users
    name: Create Workshop Users
    input:
      host: 'workshop-server.example.com'
      username: 'workshop-admin' 
      password: 'secure-password'
      script: '/opt/scripts/create-workshop-users.sh'
      scriptArgs:
        userCount: '10'
        userPrefix: 'workshop'
        password: 'Workshop2024!'
        `,
      },
    ],
    schema: {
      input: {
        host: z =>
          z
            .string()
            .describe('The hostname or IP address of the remote server'),
        port: z =>
          z
            .number()
            .optional()
            .default(22)
            .describe('SSH port number (default: 22)'),
        username: z =>
          z
            .string()
            .describe('Username for SSH authentication'),
        password: z =>
          z
            .string()
            .optional()
            .describe('Password for SSH authentication (use secrets for production)'),
        privateKey: z =>
          z
            .string()
            .optional()
            .describe('SSH private key for authentication (alternative to password)'),
        script: z =>
          z
            .string()
            .describe('Full path to the script on the remote server'),
        scriptArgs: z =>
          z
            .record(z.any())
            .optional()
            .describe('Key-value pairs of arguments to pass to the script'),
        workingDirectory: z =>
          z
            .string()
            .optional()
            .describe('Directory to execute the script from (default: user home)'),
        timeout: z =>
          z
            .number()
            .optional()
            .default(300)
            .describe('Script execution timeout in seconds (default: 300)'),
      },
      output: {
        stdout: z =>
          z
            .string()
            .describe('Output from the script execution'),
        stderr: z =>
          z
            .string()
            .describe('Error output from the script execution'),
        exitCode: z =>
          z
            .number()
            .describe('Exit code of the script execution'),
      },
    },
    async handler(ctx) {
      const {
        host,
        port = 22,
        username,
        password,
        privateKey,
        script,
        scriptArgs = {},
        workingDirectory,
      } = ctx.input;

      const ssh = new NodeSSH();

      try {
        ctx.logger.info(`Connecting to ${username}@${host}:${port}`);

        // SSH connection options
        const connectionOptions: any = {
          host,
          port,
          username,
        };

        if (privateKey) {
          connectionOptions.privateKey = privateKey;
        } else if (password) {
          connectionOptions.password = password;
        } else {
          throw new Error('Either password or privateKey must be provided');
        }

        await ssh.connect(connectionOptions);
        ctx.logger.info('SSH connection established successfully');

        // Prepare script arguments as environment variables
        let envVars = '';
        if (scriptArgs && Object.keys(scriptArgs).length > 0) {
          for (const [key, value] of Object.entries(scriptArgs)) {
            envVars += `export ${key}="${value}"; `;
          }
        }

        // Build the command
        let command = '';
        if (workingDirectory) {
          command += `cd "${workingDirectory}" && `;
        }
        command += envVars;
        command += `bash "${script}"`;

        ctx.logger.info(`Executing command: ${command}`);

        // Execute the script
        const result = await ssh.execCommand(command, {
          cwd: workingDirectory,
        });

        ctx.logger.info(`Script execution completed with exit code: ${result.code}`);
        
        if (result.stdout) {
          ctx.logger.info(`STDOUT: ${result.stdout}`);
        }
        
        if (result.stderr) {
          ctx.logger.warn(`STDERR: ${result.stderr}`);
        }

        // Set outputs for use in subsequent steps
        ctx.output('stdout', result.stdout);
        ctx.output('stderr', result.stderr);
        ctx.output('exitCode', result.code || 0);

        // If script failed, throw an error
        if (result.code !== 0) {
          throw new Error(`Script execution failed with exit code ${result.code}: ${result.stderr}`);
        }

      } catch (error) {
        ctx.logger.error(`SSH execution failed: ${error}`);
        throw error;
      } finally {
        ssh.dispose();
        ctx.logger.info('SSH connection closed');
      }
    },
  });
}