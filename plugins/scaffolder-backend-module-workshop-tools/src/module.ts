/*
 * Copyright (c) 2023-2025. Cloud Software Group, Inc. All Rights Reserved. Confidential & Proprietary
 */

import { createBackendModule } from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { createSshExecutionAction } from './actions';

/**
 * A backend module that registers workshop-related scaffolder actions
 */
export const workshopToolsModule = createBackendModule({
  moduleId: 'workshop-tools',
  pluginId: 'scaffolder',
  register({ registerInit }) {
    registerInit({
      deps: {
        scaffolderActions: scaffolderActionsExtensionPoint,
      },
      async init({ scaffolderActions }) {
        scaffolderActions.addActions(
          createSshExecutionAction(),
        );
      },
    });
  },
});