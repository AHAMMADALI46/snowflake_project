-- =========================================================
-- 2_Bronze_Layer / 04_Prod_Auto_Ingest_Pipe
-- =========================================================
USE ROLE ACCOUNTADMIN;

-- 1. Create production Snowpipe pointing to new raw_adls_stage_prod stage
CREATE OR REPLACE PIPE PROD_DB.BRONZE.raw_orders_pipe 
  INTEGRATION = 'FLOWBRIDGE_AZURE_EVENT_INT'
  AUTO_INGEST = TRUE 
  AS 
  COPY INTO PROD_DB.PUBLIC.RAW_ORDERS (RAW_DATA, FILE_NAME)
  FROM (
      SELECT $1, METADATA$FILENAME
      FROM @PROD_DB.BRONZE.raw_adls_stage_prod
  );

-- 2. Drop the old cloned dev-referencing pipe from prod schema
DROP PIPE IF EXISTS PROD_DB.PUBLIC.RAW_PIPE;
