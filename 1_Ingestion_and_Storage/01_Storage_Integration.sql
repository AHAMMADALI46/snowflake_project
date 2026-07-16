create storage integration AZURE_FLOWBRIDGE_INT
  type = external_stage
  storage_provider = azure
  enabled = true
  azure_tenant_id = '227c70f7-614a-498c-b077-ec70c446117b'
  storage_allowed_locations = (
    'azure://flowbridgestorgar.blob.core.windows.net/dev/',
    'azure://flowbridgestorgar.blob.core.windows.net/prod/'
  )
  comment = 'Azure ADLS Gen2 integration for FlowBridge project';


  desc storage integration AZURE_FLOWBRIDGE_INT;


CREATE OR REPLACE STAGE LOCAL_STAGE;