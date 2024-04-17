-- utl_sp_export_table_to_parquet_to_bucket
EXECUTE utl_sp_export_table_to_parquet_to_bucket('CUSTOMER_DEMO');

-- utl_sp_export_query_to_parquet_to_bucket
EXECUTE utl_sp_export_query_to_parquet_to_bucket('CUSTOMER_DEMO', 'SELECT * FROM CUSTOMER_DEMO');
