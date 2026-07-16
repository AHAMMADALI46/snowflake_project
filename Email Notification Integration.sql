-- =========================================================
-- 7.1 Email Notification Integration
-- =========================================================


-- 1. Set context: Use ACCOUNTADMIN role, set database = FLOW_DB, warehouse = FLOW_ETL_WH
USE ROLE ACCOUNTADMIN;
USE DATABASE FLOW_DB;
USE WAREHOUSE FLOW_ETL_WH;


-- 2. Create the notification integration
CREATE NOTIFICATION INTEGRATION IF NOT EXISTS email_notification_int
  TYPE = EMAIL
  ENABLED = TRUE
  COMMENT = 'email notification integration for pipeline health alerts';


-- 3. Verify your email (Pre-filled with your username 'ALISKSTATS6')
-- Once executed, check your email inbox and click the verification link.
CALL SYSTEM$START_USER_EMAIL_VERIFICATION('ALISKSTATS6');


-- 4. Test the email integration