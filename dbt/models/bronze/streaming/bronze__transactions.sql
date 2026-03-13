{% set env = get_env_name() %}
{% set s3_path = var(env ~ '_landing_data_s3_path') %}

{{
    config(
        catalog='<bronze_catalog_name>' ~ env,
        alias='transactions',
    )
}}

select *, _metadata.*, current_timestamp() as _load_timestamp
from stream read_files('{{ s3_path }}/streaming/transactions', format => 'json')