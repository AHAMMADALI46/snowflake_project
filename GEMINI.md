# Snowflake Project Guidelines & Conventions

This document contains repo-wide architectural guidelines, conventions, and workflows for this Snowflake project.

## 🚀 DEV to PROD Promotion Rules

When promoting objects from the Development (DEV) environment to the Production (PROD) environment, follow this rule of thumb:

### 🟢 Objects that CAN be Cloned Directly:
The following objects can be promoted directly using Snowflake's cloning capabilities (e.g. `CREATE ... CLONE`):
* **Tables**
* **Views**
* **Dynamic Tables**
* **Stages**
* **File Formats**
* **Sequences**

### 🔴 Objects that CANNOT be Cloned (Must be Recreated Manually):
The following objects reference external dependencies (such as Azure Event Grid subscriptions, change-tracking offsets, or database-specific paths) and **cannot** be cloned directly. They must be recreated manually in the PROD environment using their DDL scripts:
* **Snowpipes**
* **Streams**
* **Tasks**
* **Alerts**
