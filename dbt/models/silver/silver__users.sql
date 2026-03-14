{% set env = get_env_name() %}

{{
    config(
        catalog='<silver_catalog_prefix>' ~ env,
        alias='users',
    )
}}

select
 id,
 firstname as first_name,
 lastname as last_name
from
 {{ ref_bronze(ref_name='bronze__users', source_schema=this.schema, source_table=this.name) }}