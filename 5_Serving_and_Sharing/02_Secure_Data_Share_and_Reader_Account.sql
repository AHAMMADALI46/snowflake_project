-- =========================================================
-- 5_Serving_and_Sharing / 02_Secure_Data_Share_and_Reader_Account
-- =========================================================
USE ROLE ACCOUNTADMIN;

-- 1. Create secure data share
CREATE OR REPLACE SHARE flowbridge_prod_share COMMENT='share for serving views';

-- 2. Grant Database & Schema permissions
GRANT USAGE ON DATABASE PROD_DB TO SHARE flowbridge_prod_share;
GRANT USAGE ON SCHEMA PROD_DB.SERVING TO SHARE flowbridge_prod_share;

-- 3. Create 4 serving views on top of public Gold dynamic tables
CREATE OR REPLACE VIEW PROD_DB.SERVING.V_AGG_BASE AS SELECT * FROM PROD_DB.PUBLIC.AGG_BASE;
CREATE OR REPLACE VIEW PROD_DB.SERVING.V_ORDER_FULFILLMENT AS SELECT * FROM PROD_DB.PUBLIC.DT_ORDER_FULFILLMENT;
CREATE OR REPLACE VIEW PROD_DB.SERVING.V_SUPPLIER_PERFORMANCE AS SELECT * FROM PROD_DB.PUBLIC.DT_SUPPLIER_PERFORMANCE;
CREATE OR REPLACE VIEW PROD_DB.SERVING.V_INVENTORY_TURNOVER AS SELECT * FROM PROD_DB.PUBLIC.DT_INVENTORY_TURNOVER;

-- 4. Grant SELECT permissions on views to the share
GRANT SELECT ON VIEW PROD_DB.SERVING.V_AGG_BASE TO SHARE flowbridge_prod_share;
GRANT SELECT ON VIEW PROD_DB.SERVING.V_ORDER_FULFILLMENT TO SHARE flowbridge_prod_share;
GRANT SELECT ON VIEW PROD_DB.SERVING.V_SUPPLIER_PERFORMANCE TO SHARE flowbridge_prod_share;
GRANT SELECT ON VIEW PROD_DB.SERVING.V_INVENTORY_TURNOVER TO SHARE flowbridge_prod_share;

-- 5. Create Managed Reader Account
CREATE MANAGED ACCOUNT IF NOT EXISTS flowbridge_partner_account 
  ADMIN_NAME='flowbridge_partner_admin', 
  ADMIN_PASSWORD='PartnerAdminPassword123!', 
  TYPE=READER, 
  COMMENT='reader account for logistics partners access to prod views only';

-- 6. Link reader account dynamically (Automated via scripting or result_scan)
-- Run 'SHOW MANAGED ACCOUNTS;' first, copy its locator ID, and execute the following:
-- ALTER SHARE flowbridge_prod_share ADD ACCOUNTS = <locator_id>;
