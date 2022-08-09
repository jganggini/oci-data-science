  -- https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/export-data-csv.html#GUID-D574258F-0CE3-4757-9551-1778E4794E52
  /*-------------------------------------------------------------------------------------------.
  |                                    [CORE] DATA-LAYER                                       |
  |--------------------------------------------------------------------------------------------|
  | PROJECT       : Object Store Credentials By Autonomous Database                            |
  | LAYER         : UTILITY,                                                                   |
  | MODULE        : DATA-LAYER                                                                 |
  | DESCRIPTION   : 0.- [DBMS_CLOUD.DROP_CREDENTIAL]                                           |
  |                 1.- [DBMS_CLOUD.CREATE_CREDENTIAL]                                         |
  |                     Cree una credencial para el almac�n de objetos.                       |
  |                     Para un bucket de almacenamiento de Object Storage for Lakehouse,      |
  |                     utilizamos nuestro correo electr�nico de Oracle Cloud y el token      |
  |                     de autenticaci�n que generamos.                                       |
  |                 2.- [DBMS_CLOUD.EXPORT_DATA]                                               |
  |                     Para exportar datos como archivos CSV en Object Storage for Lakehouse. |
  `-------------------------------------------------------------------------------------------*/
    
  --0.- [DBMS_CLOUD.DROP_CREDENTIAL]
    BEGIN
      DBMS_CLOUD.DROP_CREDENTIAL(
        credential_name => 'DEF_CRED_LAKEHOUSE'
      );
    END;
    /
    
  --1.- [DBMS_CLOUD.CREATE_CREDENTIAL]
    BEGIN
      DBMS_CLOUD.CREATE_CREDENTIAL(
        credential_name => 'DEF_CRED_LAKEHOUSE',
        username        => 'user1@example.com',
        password        => 'password'
      );
    END;
    /
    
  --2.- [DBMS_CLOUD.EXPORT_DATA] 
    BEGIN
      DBMS_CLOUD.EXPORT_DATA(
        credential_name => 'DEF_CRED_LAKEHOUSE',
        file_uri_list   => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/namespace-string/b/bucketname/o/dept_export/file-name.csv',
        query           => 'SELECT * FROM SH.CUSTOMERS',
        format          => JSON_OBJECT('type' value 'csv', 'delimiter' value '|')
      );
    END;
    /