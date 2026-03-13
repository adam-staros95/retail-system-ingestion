/*
This macro do not bring extra value only one environment is supported.
Read Medium post to understand why `ref_bronze` macro is useful in multi-environment setup.
*/
{% macro ref_bronze(ref_name, source_schema, source_table) %}
    {% if get_env_name() == 'dev' %} {{ ref(ref_name) }}
    {% else %} <bronze_catalog_name>.{{ source_schema }}.{{ source_table }}
    {% endif %}
{% endmacro %}
