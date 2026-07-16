# 🚀 FlowBridge Real-time Data Engineering Pipeline

An enterprise-grade, end-to-end Real-time Medallion Data Pipeline and serving architecture built natively in **Snowflake**, integrated with **Azure ADLS Gen2** storage, and structured as a robust production repository.

---

## 📐 Architecture & Data Flow

This pipeline leverages Snowflake's modern streaming primitives (Streams, Tasks, Snowpipe, and Dynamic Tables) to process, cleanse, model, and securely share streaming order data in real time:

```
                                  [ REAL-TIME MEDALLION PIPELINE ]
                                  
  +------------------+         +------------------+         +--------------------------+
  |  Azure ADLS Gen2 |         |  Snowflake Stage |         |    Snowpipe Auto-Ingest  |
  |  (JSON Streams)  |  ---->  |   (ADLS_STAGE)   |  ---->  |   (raw_orders_pipe)      |
  +------------------+         +------------------+         +--------------------------+
                                                                         |
                                                                         v
                                                            +--------------------------+
                                                            |       Bronze Layer       |
                                                            |   (RAW_ORDERS Table)     |
                                                            +--------------------------+
                                                                         |
                                                                         v (Change Stream)
                                                            +--------------------------+
                                                            |    RAW_ORDERS_STREAM     |
                                                            +--------------------------+
                                                                         |
                                                                         v (Scheduled Task)
                                                            +--------------------------+
                                                            |   SP_LOAD_STG_ORDERS()   |
                                                            |  Bronze -> Silver Load   |
                                                            +--------------------------+
                                                                         |
                                       +---------------------------------+---------------------------------+
                                       |                                                                   |
                                       v                                                                   v
                          +--------------------------+                                        +--------------------------+
                          |   Silver: Clean Table    |                                        |    Dead Letter Table     |
                          |  (STG_ORDERS Table)      |                                        |  (DEAD_LETTER_ORDERS)    |
                          +--------------------------+                                        +--------------------------+
                                       |
                                       v (Change Stream)
                          +--------------------------+
                          |    STG_ORDERS_STREAM     |
                          +--------------------------+
                                       |
                                       v (Task DAG Dependency)
                          +--------------------------+
                          |   SP_LOAD_FACT_ORDERS()  |
                          |   Silver -> Star Load    |
                          +--------------------------+
                                       |
                                       +---------------------------------+
                                       |                                 |
                                       v (Dimensional Tables)            v (Fact Table)
                          +--------------------------+      +--------------------------+
                          | DIM_CUSTOMER / DIM_SUPP  |      |   FACT_ORDERS Table      |
                          | DIM_WAREHOUSE / DIM_SHIP |      |   (Star Schema Model)    |
                          +--------------------------+      +--------------------------+
                                       |                                 |
                                       +---------------------------------+
                                                               |
                                                               v (1-Minute Refresh)
                                                    +--------------------------+
                                                    |        Gold Layer        |
                                                    |  (4 Analytical DTs)      |
                                                    +--------------------------+
                                                               |
                                                               v (Abstraction Layer)
                                                    +--------------------------+
                                                    |     Serving Schema       |
                                                    |     (4 Secure Views)     |
                                                    +--------------------------+
                                                               |
                                                               v (Secure Data Share)
                                                    +--------------------------+
                                                    |  flowbridge_prod_share   |
                                                    +--------------------------+
                                                               |
                                                               v (Direct Access)
                                                    +--------------------------+
                                                    |  Logistics Reader Account|
                                                    |  (External Partners)     |
                                                    +--------------------------+
```

---

## 📁 Repository Directory Structure

The repository is organized following the logical stages of an enterprise real-time data engineering lifecycle:

```
snowflake_project/
├── 1_Ingestion_and_Storage/
│   ├── 01_Storage_Integration.sql    # Creates Storage Integration (AZURE_FLOWBRIDGE_INT) with ADLS Gen2
│   ├── 02_File_Format.sql            # Defines the JSON File Format (JSON_FORMAT)
│   ├── 03_Local_Stage.sql            # Defines local stage and copy commands for manual uploads
│   ├── 04_External_Stage.sql         # Configures External ADLS Gen2 Storage Stage pointing to Azure
│   └── 05_ADLS_Stage_List.sql        # Utility scripts to test external stage and list files
│
├── 2_Bronze_Layer/
│   ├── 01_Raw_Orders_Table.sql       # Schema for Bronze transient table (RAW_ORDERS)
│   ├── 02_Bronze_Stage_Copy.sql      # Dev/manual copy scripts to load RAW_ORDERS
│   ├── 03_Raw_Pipe_Ingest.sql        # Basic Snowflake Pipe definitions
│   └── 04_Prod_Auto_Ingest_Pipe.sql  # Production Auto-Ingest Snowpipe bound to Azure Event Grid
│
├── 3_Silver_Layer/
│   ├── 01_Streams_and_Bronze_to_Silver_Procedure.sql # RAW_ORDERS stream, SP_LOAD_STG_ORDERS sp, and DLQ logic
│   └── 02_Silver_Integration_Queries.sql             # Silver data verification and profiling
│
├── 4_Gold_Layer/
│   ├── 01_Gold_Dynamic_Tables.sql            # Aggregation tables & analytical dynamic tables (AGG_BASE, etc.)
│   └── 02_Star_Schema_Dimensional_Model.sql  # Star Schema facts, dimensions, and SP_LOAD_FACT_ORDERS() sp
│
├── 5_Serving_and_Sharing/
│   ├── 01_DEV_to_PROD_Promotion.sql                   # Database promotion utilities, schema cloning & grants
│   ├── 02_Secure_Data_Share_and_Reader_Account.sql    # flowbridge_prod_share, secure views, and Reader Account
│   └── 03_DB_Initialization_Utilities.sql             # SQL scratchpad for database-level creations
│
└── 6_Monitoring_and_Alerts/
    ├── 01_Email_Notification_Integration.sql # Email integration setup (ACCOUNTADMIN)
    └── 02_Pipeline_Health_Alert.sql          # 5-minute automated alert checks (Snowpipe, Tasks, DTs)
```

---

## 🛠️ Detailed Setup & Execution Flow

To set up and run the entire pipeline in your Snowflake instance, follow these steps sequentially:

### 1️⃣ Core Infrastructure Setup
1. **Storage Integration**: Run `1_Ingestion_and_Storage/01_Storage_Integration.sql` (under `ACCOUNTADMIN` role) to establish the ADLS Gen2 integration.
2. **File Format**: Run `1_Ingestion_and_Storage/02_File_Format.sql` to define the JSON parser format.
3. **External Stage**: Run `1_Ingestion_and_Storage/04_External_Stage.sql` to link to your ADLS Gen2 `/dev/` and `/prod/` container paths.

### 2️⃣ Ingestion & Bronze Layer
1. **Bronze Table**: Create the raw order landing table using `2_Bronze_Layer/01_Raw_Orders_Table.sql`.
2. **Auto-Ingest Snowpipe**: Run `2_Bronze_Layer/04_Prod_Auto_Ingest_Pipe.sql` to set up your production auto-ingest Snowpipe (`raw_orders_pipe`), bound to Azure Event Grid notifications.

### 3️⃣ Transformation & Silver Layer
1. **Raw Orders Stream**: Run `3_Silver_Layer/01_Streams_and_Bronze_to_Silver_Procedure.sql` to create `RAW_ORDERS_STREAM` capturing new raw landing records.
2. **Bronze-to-Silver SP**: Execute the stored procedure `SP_LOAD_STG_ORDERS()` in the same file. This reads from the stream, parses JSON fields, validates `order_id` (separating valid records into `STG_ORDERS` and quarantined records into `DEAD_LETTER_ORDERS`), and flushes change tracking offsets.

### 4️⃣ Modeling & Gold Layer
1. **Star Schema Model**: Run `4_Gold_Layer/02_Star_Schema_Dimensional_Model.sql` to create dimension tables (`DIM_CUSTOMER`, etc.), fact table (`FACT_ORDERS`), staging stream (`STG_ORDERS_STREAM`), and the second stored procedure `SP_LOAD_FACT_ORDERS()`. This procedure performs dimensional key lookups and inserts incremental records into your facts and dimensions.
2. **Task DAG Setup**: Run `3_Silver_Layer/01...` and `4_Gold_Layer/02...` to deploy tasks:
   * **`BRONZE_TO_SILVER_TASK`**: Runs every 5 minutes when the raw stream has data, executing `SP_LOAD_STG_ORDERS()`.
   * **`SILVER_TO_STAR_TASK`**: Runs immediately after the root task completes, executing `SP_LOAD_FACT_ORDERS()`.
3. **Gold Analytical Layer**: Run `4_Gold_Layer/01_Gold_Dynamic_Tables.sql` to deploy 4 real-time Dynamic Tables. These auto-refresh every 1 minute to compute pipeline KPIs, supplier performance, and warehouse inventory turnovers.

### 5️⃣ Database Promotion & Secure Data Sharing
1. **PROD Database cloning**: Run `5_Serving_and_Sharing/01_DEV_to_PROD_Promotion.sql` to clone your schemas (`BRONZE` and `PUBLIC`) from `FLOW_DB` into `PROD_DB`, initialize production schemas (`SILVER`, `GOLD`, `SERVING`), and transfer ownership to `SYSADMIN`.
2. **Secure Sharing**: Run `5_Serving_and_Sharing/02_Secure_Data_Share_and_Reader_Account.sql` to create `flowbridge_prod_share`, deploy 4 secure abstraction views under the `SERVING` schema, and provision your logistics partners' managed reader account.

### 6️⃣ Proactive Monitoring & Pipeline Alerts
1. **Email Integration**: Configure your SMTP/Email integration using `6_Monitoring_and_Alerts/01_Email_Notification_Integration.sql`.
2. **Automated Health Alert**: Deploy and resume `6_Monitoring_and_Alerts/02_Pipeline_Health_Alert.sql`. This is scheduled every 5 minutes to verify:
   * Bronze Copy Failures
   * Silver Task Failures
   * Gold Dynamic Table Refresh Failures
   
   If any failure is detected, it automatically sends alert emails telling administrators which layer requires review.

---

## 🏅 Production Features
* **Medallion Architecture**: Segregates concerns between raw landing (Bronze), cleaned & validated schemas (Silver), and aggregates (Gold).
* **Idempotent Ingestion**: Leveraging Change-Data-Capture (CDC) Streams to process only incremental rows, minimizing compute overhead.
* **Auto-Ingestion (Event-Driven)**: Integrates directly with cloud-native Event Grid/Queues via Snowpipe for millisecond-latency ingestion.
* **Secure Sharing**: Uses Snowflake's secure shares and managed reader accounts to share analytical insights externally without moving data.
* **Proactive Monitoring**: Employs real-time alerts and email notifications to keep engineers notified of pipeline health.
