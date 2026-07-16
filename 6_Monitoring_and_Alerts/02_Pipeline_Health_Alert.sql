FROM TABLE(FLOW_DB.INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY())
    WHERE SCHEMA_NAME = 'GOLD'
      AND STATE = 'FAILED'
      AND REFRESH_START_TIME >= DATEADD(minute, -5, CURRENT_TIMESTAMP())
  ))
  THEN CALL SYSTEM$SEND_EMAIL(
    'email_notification_int',
    'aliskstats6@gmail.com',
    'Pipeline Alert - FlowBridge Project',
    'Warning: One or more failures detected in the FlowBridge data pipeline.\n\nPlease check the Bronze, Silver, or Gold layers via Snowsight Monitoring > Query/Task History.'
  );


-- 3. Activate the alert (Alerts are created in a suspended state by default)
ALTER ALERT FLOW_DB.BRONZE.pipeline_health_alert RESUME;


-- 4. Verify that the alert has been created and started successfully
SHOW ALERTS IN DATABASE FLOW_DB;


-- 5. Review the alert execution history for the last 1 hour
SELECT *
FROM TABLE(FLOW_DB.INFORMATION_SCHEMA.ALERT_HISTORY(
  SCHEDULED_TIME_RANGE_START => DATEADD(hour, -1, CURRENT_TIMESTAMP())
))
ORDER BY SCHEDULED_TIME DESC
LIMIT 10;