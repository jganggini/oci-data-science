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
    
  --0.- [DBMS_CLOUD.DROP_CREDENTIAL]
    BEGIN
      DBMS_CLOUD.DROP_CREDENTIAL(
        credential_name => 'DEF_CRED_LAKEHOUSE_TOK'
      );
    END;
    /
    
  --1.- [DBMS_CLOUD.CREATE_CREDENTIAL]
    BEGIN
      DBMS_CLOUD.CREATE_CREDENTIAL(
        credential_name => 'DEF_CRED_LAKEHOUSE_TOK',
        username        => 'user1@example.com',
        password        => 'password'
      );
    END;
    /
    
  --2.- [DBMS_CLOUD.EXPORT_DATA]
  --https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/format-options-json.html#GUID-3CE7574F-E78B-49D6-9F32-DC00AEE418F4
    BEGIN
      DBMS_CLOUD.EXPORT_DATA(
        credential_name => 'DEF_CRED_LAKEHOUSE_TOK',
        --https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/file-uri-formats.html#GUID-F4295FA3-5A1E-41C4-91EB-D450E082AF47
        file_uri_list   => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/namespace-string/b/bucketname/o/dept_export/file-name.csv',
        query           => 'SELECT * FROM SH.CUSTOMERS',
        format          => JSON_OBJECT('type' value 'csv', 'delimiter' value ',', 'maxfilesize' value 2147483648)
      );
    END;
    /

  --3.- [DBMS_CLOUD.CREATE_CREDENTIAL] DBMS_CLOUD REST API
    -- https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-E038D42F-009E-477D-96E7-60944A510474
    BEGIN
        DBMS_CLOUD.CREATE_CREDENTIAL (
            credential_name => 'DEF_CRED_LAKEHOUSE_API',
            user_ocid       => 'ocid1.user.oc1..aaaaaaaawbh6e75hxk3st7athfu3ocaj76sbyewl5bf7f4pef6hs23aje7eq',
            tenancy_ocid    => 'ocid1.tenancy.oc1..aaaaaaaavl2ndgiiefoo2u4a7atlq2czcwyiu5zzb6rzwwpeyt5o2xmtaxwa',
            private_key     =>
'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDC3GD+9ddljkNt
1R9R2PaQizwn7BNvBEAi30jYk1hr4jsYch9+vAdE+6qNrKTtxEU2NdtolYl8EzPS
n4WnZQy0DGZ+jXKCS2uonkMA9EO7dUxSHvhHkf1wHha1x8g9DirFjrfEzEV/EjLZ
2xDDD2cR8Gv/+Oxk6Y7e7WHOXs7KeoznF+Jk5wNKzT+VWDl4O5dmxpqhsm3YIjzE
r9jIzE0ErwIgjbzDWWxRi2SYrPz8EDDhgVK5Xer4ujTyKfwOi1caeNMpWwCDfCmD
tS9ewUesvziGB8V9qt8N2Le72Tp6IrKFoOf9JnjjLx1elKkvfyTKPTe/o9YrH0FY
o3tM/2zJAgMBAAECggEAW7trXhtVn1VtoNLnv5wn1rv1QcX9EBIsLz52CJ60zXTe
5Q80jHDv6yWekLtpmRUAkBiihYWAB4zypIC8ZqVHaas8xO7JrVTcBbEbUeOrzx/V
IgO6VdcAPDut7T1zomp88CvTjy2qubtTfQOHzIv/tY49CW+huY/J1mBh3sj7CI39
o45B19O1PSSOr04pHYNaRhda6enQH+btM23BpLCijbx7O4AzY2MSMz5FX4Qo4URI
TPd2MOlKc7BlsYpkDY5Jjv81dE/KITvmLb1DsZS4JokCPIdm+UxJWNXwZje3b2zn
FU90eQsdBhRYKhcvUa/Ozl0QUBAA7INZ5qkiCDj5EQKBgQDzG59MBnJ0RRIUyj8r
WMb8IlljVFw2Dg/ZACu9TIS3bwbarRhsUCPAdzV+i0epq4VG++h8a9Aqt0+ZTrJm
Y8EA9L++DSbKRqmf2WfCesQ6MUbNY/vvgfjet7vgMfcXa775ZmKwmkPdOLpR/tSf
Z3nuh4+lvjJXIwkrQm8TZP36iwKBgQDNMcQErXgzaLDhJPApJJAfljHt1yv7gDJ5
2mW6nVoT7AbwUkWx3kMzL3dADPwbitldDuvjJQg64xkUgMg5kDfoCwgBmRcd1Xud
u2Z48snCNkIUMZldfr0IKPqtrw5VUGcv9arNNHztgRbYmM91z1ReIz9a3dO7iLKx
eA8YAUWkewKBgQCqEIqxTllGyQLLFGh4VFRvEUBi4iLXlaK0dRAkDqFRCRRMaYaK
Ts2T2FDNw3VQVjKX46VRVMJ8/1tprcnTIrljh9OSifS20BPdROL3A5a99rbG+8jE
VbHZa8K8JXfrJG6mXV9wl5od6Y89yPzIvkRn/uEYWyMwHcxOPN0jPiUF3QKBgFvC
ZHDfDgCXUXntJcSQSC8H4F4GufFm+6uIIbPZB94ez1+KuwX2acCq+j3XUKoUZm15
7byO4+ZJhf6oNGGhf46x2Cu2xSKfQ/9ePU3a7KR/1P7oyzeHJItQoAEpZlR6dxp4
VqAbV75x2sCTXTrGs2jBhGRjDHsxfw9jrARFFVqfAoGAC+Qecf8MEkq7gP320HkN
QEYXmAKnsxbH+W7Fi/PwY2FkAkXJZNZICTIwxpA6JYK6DqPbrmmAw2aNNi+z0Owc
LsSgRw55ccmNCjhu0Rtnl+QZwpLBX27AENQy4S2FFADqG5OZSsPSaGzRzxataPNB
xcqtI7DcI038IZdbhBUUcRQ=',
            fingerprint     => '88:e4:6d:a3:4a:a5:d5:15:07:4d:36:77:c2:93:cc:9a');
    END;
    /