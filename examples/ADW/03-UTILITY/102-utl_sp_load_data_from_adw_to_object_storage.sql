CREATE OR REPLACE PROCEDURE utl_sp_load_data_from_adw_to_object_storage(
  par_credential_name_token   IN   VARCHAR2 DEFAULT 'DEF_CRED_LAKEHOUSE_TOK',
  par_credential_name_api_key IN   VARCHAR2 DEFAULT 'DEF_CRED_LAKEHOUSE_API',
  par_region                  IN   VARCHAR2 DEFAULT 'us-ashburn-1',
  par_namespace_string        IN   VARCHAR2 DEFAULT 'idlhjo6dp3bd',
  par_bucket_name             IN   VARCHAR2 DEFAULT 'obj-demo',
  par_folder_name             IN   VARCHAR2 DEFAULT 'lakehouse-demo/',
  par_file_name               IN   VARCHAR2 DEFAULT 'customers.csv',
  par_table_name              IN   VARCHAR2 DEFAULT 'SH.CUSTOMERS')
AS
  var_object_name VARCHAR2(4000);
  var_resp        DBMS_CLOUD_TYPES.resp;
BEGIN
  /*----------------------------------------------------------------------------------------------------------------.
  |                                               [UTILITY] DATA-LAYER                                              |
  |-----------------------------------------------------------------------------------------------------------------|
  | PROJECT       : LAKEHOUSE                                                                                       |
  | LAYER         : UTILITY                                                                                         |
  | MODULE        : PROCEDURE                                                                                       |
  | DESCRIPTION   : 0.- [Pre-Requisitos]                                                                            |
  |                     => OCI Object Store Credentials By Autonomous Database                                      |
  |                     https://github.com/jganggini/oci-data-science/blob/main/utilities-oci-data-science/ADW/03-UTILITY/101-dms_cloud-utility.sql
  |                     => DBMS_CLOUD Package Format Options for EXPORT_DATA with Text Files (CSV, JSON, and XML)   |
  |                     https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/format-options-json.html#GUID-3CE7574F-E78B-49D6-9F32-DC00AEE418F4
  |                     => DBMS_CLOUD REST API Examples                                                             |                   
  |                     https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-E038D42F-009E-477D-96E7-60944A510474
  |                 1.- [DBMS_CLOUD.EXPORT_DATA]                                                                    |
  |                     Exporta los datos de una tabla a OCI Object Storage for Lakehouse.                          |
  |                 2.- [DBMS_CLOUD.LIST_OBJECTS]                                                                   |
  |                     Listas los objetos que existen en una ruta dentro de OCI Object Storage for Lakehouse.      |
  |                 3.- [DBMS_CLOUD.SEND_REQUEST]                                                                   |
  |                     Enviar solicitudes de la API de REST (renameObject).                                        |
  |-----------------------.----------------------.------------------------------------------------------------------|
  | DATA-LAYER            | SCHEMA NAME          | OBJECT NAME                                                      |
  |-----------------------|----------------------|------------------------------------------------------------------|
  | UTILITY               | UTL                  | sp_load_data_from_adw_to_object_storage                          |
  `-----------------------------------------------------------------------------------------------------------------|
                                                                                                                    |
  --[DBMS_CLOUD.EXPORT_DATA]---------------------------------------------------------------------------------------*/
    DBMS_CLOUD.EXPORT_DATA(                                                                                       --|
        credential_name => par_credential_name_token,                                                             --|
        file_uri_list   => 'https://objectstorage.'||par_region||                                                 --|
                           '.oraclecloud.com/n/'||par_namespace_string||                                          --|
                           '/b/'||par_bucket_name||'/o/'||par_folder_name||par_file_name,                         --|
        query           => 'SELECT * FROM '||par_table_name,                                                      --|
        format          => JSON_OBJECT('type'        value 'csv',       'delimiter' value ',',                    --|
                                       'maxfilesize' value 2147483648,  'header'    value true)                   --|
    );                                                                                                            --|
  /*[fin] Step 01--------------------------------------------------------------------------------------------------*/
                                                                                                                  --|
  --[DBMS_CLOUD.LIST_OBJECTS]---------------------------------------------------------------------------------------|
    SELECT OBJECT_NAME INTO var_object_name FROM DBMS_CLOUD.LIST_OBJECTS(par_credential_name_token,               --|
                                                 'https://objectstorage.'||par_region||                           --|
                                                 '.oraclecloud.com/n/'||par_namespace_string||                    --|
                                                 '/b/'||par_bucket_name||'/o/'||par_folder_name);                 --|
  --[fin] Step 02--------------------------------------------------------------------------------------------------*/
                                                                                                                  --|
  --[DBMS_CLOUD.SEND_REQUEST]---------------------------------------------------------------------------------------|
    var_resp := DBMS_CLOUD.SEND_REQUEST(                                                                          --|
                    credential_name => par_credential_name_api_key,                                               --|
                    uri             => 'https://objectstorage.'||par_region||                                     --|
                                       '.oraclecloud.com/n/'||par_namespace_string||                              --|
                                       '/b/'||par_bucket_name||'/actions/renameObject',                           --|
                    method          => DBMS_CLOUD.METHOD_POST,                                                    --|
                    body            => UTL_RAW.cast_to_raw(                                                       --|
                                       JSON_OBJECT('sourceName' value par_folder_name||var_object_name,           --|
                                                   'newName'    value par_folder_name||par_file_name))            --|
                );                                                                                                --|
    dbms_output.put_line('result: ' || DBMS_CLOUD.get_response_text(var_resp));                                   --| 
  --[fin] Step 03--------------------------------------------------------------------------------------------------*/
END;
/