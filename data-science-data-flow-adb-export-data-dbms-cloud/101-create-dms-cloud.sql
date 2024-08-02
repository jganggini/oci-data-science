  -- https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/export-data-csv.html#GUID-D574258F-0CE3-4757-9551-1778E4794E52
  /*-------------------------------------------------------------------------------------------.
  |                                    [CORE] DATA-LAYER                                       |
  |--------------------------------------------------------------------------------------------|
  | PROJECT       : Object Store Credentials By Autonomous Database                            |
  | LAYER         : UTILITY,                                                                   |
  | MODULE        : DATA-LAYER                                                                 |
  | DESCRIPTION   : 0.- [DBMS_CLOUD.DROP_CREDENTIAL]                                           |
  |                 1.- [DBMS_CLOUD.CREATE_CREDENTIAL]                                         |
  |                     Cree una credencial (Auth Tokens) para conectarnos a                   |
  |                     un bucket de almacenamiento de OCI Object Storage for Lakehouse,       |
  |                     utilizamos nuestro correo electronico de Oracle Cloud y el Auth Tokens |
  |                     de autenticacion que generamos.                                        |
  |                 2.- [DBMS_CLOUD.EXPORT_DATA]                                               |
  |                     Para exportar datos como archivos CSV en Object Storage for Lakehouse. |
  |                 3.- [DBMS_CLOUD.CREATE_CREDENTIAL] DBMS_CLOUD REST API                     |
  `-------------------------------------------------------------------------------------------*/
  
  /*-------------------.--------------------.-----------------------------------------------------------------------.
  | PROJECT            | LAYER              | MODULE             | NAME                                             |
  |--------------------|--------------------|--------------------|--------------------------------------------------|
  | LAKEHOUSE          | UTILITY            | DATA-LAYER         | Object Store Credentials By Autonomous Database  |
  |-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  | [Pre-Requisitos]                                                                                                |
  | a) Export Data as Parquet to Cloud Object Storage                                                               |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/export-data-parquet.html#GUID-7C1CADFE-3A39-416D-A0FF-96AC447489D0
  |    The values you provide for username and password depend on the Cloud Object Storage service you are using.   |
  | b) DBMS_CLOUD Package Oracle Data Type to Parquet Mapping                                                       |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/data-type-mapping-oracle-parquet.html#GUID-AEFEC843-027D-44A0-A8FA-892C523CDA38
  |    Describes the valid format parameter options for DBMS_CLOUD.EXPORT_DATA with text file formats, CSV, JSON,   | 
  |    Parquet, or XML, and for Oracle Data Pump.                                                                   |
  | c) DBMS_CLOUD REST API Examples                                                                                 |
  |    > https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-E038D42F-009E-477D-96E7-60944A510474
  |                                                                                                                 |
  `----------------------------------------------------------------------------------------------------------------*/

  --[Step-01][DBMS_CLOUD.DROP_CREDENTIAL]--------------------------------------------------------------------------*/
  BEGIN
    DBMS_CLOUD.DROP_CREDENTIAL(
      credential_name => 'DEF_CRED_LAKEHOUSE_TOK'
    );
  END;
  /
    
  --[Step-02][DBMS_CLOUD.CREATE_CREDENTIAL]------------------------------------------------------------------------*/

  BEGIN
    DBMS_CLOUD.CREATE_CREDENTIAL(
      credential_name => 'DEF_CRED_LAKEHOUSE_TOK',
      username        => 'user1@example.com',
      password        => 'password'
    );
  END;
  /
  
  --[Step-03][NLS Session Parameters]------------------------------------------------------------------------------*/
  ALTER SESSION SET NLS_DATE_FORMAT = "MM/DD/YYYY";
  ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH:MI:SS.FF';
  ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT='YYYY-MM-DD HH:MI:SS.FF TZH:TZM';

  --[Step-04][DBMS_CLOUD.EXPORT_DATA]------------------------------------------------------------------------------*/
  BEGIN
    DBMS_CLOUD.EXPORT_DATA(
      credential_name => 'DEF_CRED_NAME',
      file_uri_list   => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/namespace-string/b/bucketname/o/dept_export/CUSTOMER_DEMO.parquet',
      query           => 'SELECT * FROM CUSTOMER_DEMO',
      format          => JSON_OBJECT('type' value 'parquet', 'compression' value 'snappy'));
  END;
  /

  --[Step-05][DBMS_CLOUD.CREATE_CREDENTIAL]------------------------------------------------------------------------------*/
  BEGIN
      DBMS_CLOUD.CREATE_CREDENTIAL (
          credential_name => 'DEF_CRED_LAKEHOUSE_API',
          user_ocid       => 'ocid1.user.oc1..***',
          tenancy_ocid    => 'ocid1.tenancy.oc1..***',
          private_key     =>
'****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
****************************************************************
************************',
            fingerprint     => '**:**:**:**:**:**:**:**:**:**:**:**:**:**:**:**');
  END;
  /

  --[Step-06][Lists all credentials visible to the user]-----------------------------------------------------------------*/
  SELECT CREDENTIAL_NAME, USERNAME, COMMENTS FROM ALL_CREDENTIALS;