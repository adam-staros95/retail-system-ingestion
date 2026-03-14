{% set env = get_env_name() %}

{{
    config(
        catalog='<silver_catalog_prefix>' ~ env,
        alias='transactions',
    )
}}

select
 id,
 amount
from
 {{ ref_bronze(ref_name='bronze__transactions', source_schema=this.schema, source_table=this.name) }}
