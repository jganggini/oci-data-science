create or replace PROCEDURE utl_sp_export_query_to_parquet_to_bucket(
  par_folder_name             IN   VARCHAR2 DEFAULT 'CUSTOMER_DEMO',
  par_query                   IN   VARCHAR2 DEFAULT 'SELECT * FROM CUSTOMER_DEMO'
) AS
  par_file_name               VARCHAR2(250) := par_folder_name || '.parquet';
  par_table_name              VARCHAR2(250) := 'ADMIN.' || par_folder_name;
  par_credential_name_token   VARCHAR2(250) := 'DEF_CRED_LAKEHOUSE_TOK';
  par_credential_name_api_key VARCHAR2(250) := 'DEF_CRED_LAKEHOUSE_API';
  par_region                  VARCHAR2(250) := 'us-ashburn-1';
  par_namespace_string        VARCHAR2(250) := '************';
  par_bucket_name             VARCHAR2(250) := 'DLK1LAG';
  TYPE t_object_name_tab      IS TABLE OF VARCHAR2(250);
  v_object_names              t_object_name_tab;
  --UTL.TIME
  v_start_time  NUMBER;
  v_end_time     NUMBER;
  v_elapsed_time NUMBER;
BEGIN
  /*-------------------.--------------------.-----------------------------------------------------------------------.
  | PROJECT            | LAYER              | MODULE             | NAME                                             |
  |--------------------|--------------------|--------------------|--------------------------------------------------|
  | LAKEHOUSE          | UTILITY            | PROCEDURE          | Export Query to Parquet to Bucket                |
  |-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  | [Pre-Requisitos]                                                                                                |
  | a) Export Data as Parquet to Cloud Object Storage                                                               |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/export-data-parquet.html        |
  |    Shows the steps to export table data from your Autonomous Database to Cloud Object Storage as Parquet data   | 
  |    by specifying a query.                                                                                       |
  | b) DBMS_CLOUD Package Format Options for EXPORT_DATA                                                            |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/format-options-json.html#GUID-3CE7574F-E78B-49D6-9F32-DC00AEE418F4
  |    Describes the valid format parameter options for DBMS_CLOUD.EXPORT_DATA with text file formats, CSV, JSON,   | 
  |    Parquet, or XML, and for Oracle Data Pump.                                                                   |
  | c) DBMS_CLOUD REST API Examples                                                                                 |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-E038D42F-009E-477D-96E7-60944A510474
  |    Shows examples using DBMS_CLOUD.SEND_REQUEST to create and delete an Oracle Cloud Infrastructure Object      | 
  |    Storage bucket, and an example to list all compartments in the tenancy.                                      |
  |                                                                                                                 |
  | [Steps]                                                                                                         |
  | 1) [Step-01][DBMS_CLOUD Package Oracle Data Type to Parquet Mapping]                                            |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/data-type-mapping-oracle-parquet.html#GUID-AEFEC843-027D-44A0-A8FA-892C523CDA38
  |    Describes the mapping of Oracle data types to Parquet data types.                                            |
  | 2) [Step-02][DBMS_CLOUD.LIST_OBJECTS]                                                                           |
  |    > https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_CLOUD.html#GUID-52801F96-8280-4FE0-8782-E194F4360E6F
  |    This function lists objects in the specified location on object store.                                       |
  | 3) [Step-03][DBMS_CLOUD.SEND_REQUEST:DELETE]                                                                    |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/dedicated/dbosc/#GUID-BD4B4FBC-660A-4801-9B0D-58B19A32A79B
  |    DBMS_CLOUD supports GET, PUT, POST, HEAD and DELETE HTTP methods.                                            |
  | 4) [Step-04][DBMS_CLOUD.EXPORT_DATA]                                                                            |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/format-options-json.html        |
  |    DBMS_CLOUD Package Format Options for EXPORT_DATA.                                                           |
  `----------------------------------------------------------------------------------------------------------------*/
  v_start_time := DBMS_UTILITY.GET_TIME; 
  --[Step-01][DBMS_CLOUD Package Oracle Data Type to Parquet Mapping]----------------------------------------------*/
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''MM/DD/YYYY''';                                       --|
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_TIMESTAMP_FORMAT = ''YYYY-MM-DD HH24:MI:SS.FF''';                    --|
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = ''YYYY-MM-DD HH24:MI:SS.FF TZH:TZM''';         --|
                                                                                                                  --|
  /*[END][Step-01]-------------------------------------------------------------------------------------------------*/

  --[Step-02][DBMS_CLOUD.LIST_OBJECTS]----------------------------------------------------------------------------*/
    SELECT OBJECT_NAME BULK COLLECT INTO v_object_names                                                           --|
    FROM DBMS_CLOUD.LIST_OBJECTS(par_credential_name_token,                                                       --|
                                 'https://objectstorage.'||par_region||                                           --|
                                 '.oraclecloud.com/n/'||par_namespace_string||                                    --|
                                 '/b/'||par_bucket_name||'/o/'||par_folder_name);                                 --|
  /*[END][Step-02]-------------------------------------------------------------------------------------------------*/

  --[Step-03][DBMS_CLOUD.SEND_REQUEST:DELETE]----------------------------------------------------------------------*/
    FOR i IN 1..v_object_names.COUNT LOOP                                                                         --|
        DBMS_OUTPUT.PUT_LINE('Nombre de objeto: ' || v_object_names(i));                                          --|
        DBMS_CLOUD.SEND_REQUEST(                                                                                  --|
        credential_name => par_credential_name_api_key,                                                           --|
        uri             => 'https://objectstorage.'||par_region||                                                 --|
                           '.oraclecloud.com/n/'||par_namespace_string||                                          --|
                           '/b/'||par_bucket_name||'/o/'||par_folder_name||'/'||v_object_names(i),                --|
        method          => 'DELETE');                                                                             --|
    END LOOP;                                                                                                     --|
  /*[END][Step-03]-------------------------------------------------------------------------------------------------*/

  --[Step-04][DBMS_CLOUD.EXPORT_DATA]------------------------------------------------------------------------------*/
    DBMS_CLOUD.EXPORT_DATA(                                                                                       --|
        credential_name => par_credential_name_token,                                                             --|
        file_uri_list   => 'https://objectstorage.'||par_region||                                                 --|
                           '.oraclecloud.com/n/'||par_namespace_string||                                          --|
                           '/b/'||par_bucket_name||'/o/'||par_folder_name||'/'||par_file_name,                    --|
        query           => par_query,                                                                             --|
        format          => JSON_OBJECT('type' value 'parquet',  'compression' value 'snappy')                     --|
    );                                                                                                            --|
  /*[END][Step-04]-------------------------------------------------------------------------------------------------*/
  
  --[DBMS_OUTPUT]--------------------------------------------------------------------------------------------------*/
    v_end_time := DBMS_UTILITY.GET_TIME;                                                                          --|
    v_elapsed_time := (v_end_time - v_start_time) / 100;                                                          --|
    DBMS_OUTPUT.PUT_LINE('[Step-02][DBMS_CLOUD.LIST_OBJECTS]: ' || v_elapsed_time || ' Seconds.');                --|
  /*[END][DBMS_OUTPUT]---------------------------------------------------------------------------------------------*/

END;