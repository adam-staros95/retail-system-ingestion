{% macro get_env_name(verbose=False) %}
    {% set host = target.host %}
    {% if verbose %} {% do log("Resolved DBT_DATABRICKS_HOST: " ~ host, info=True) %} {% endif %}

    {% if host is none %}
        {{ exceptions.raise_compiler_error("Environment variable DBT_DATABRICKS_HOST is not set.") }}

    {% elif var('dev_workspace_name') in host %}
        {% set env_name = 'dev' %}
        {% if verbose %} {% do log("Databricks environment: " ~ env_name, info=True) %}
        {% endif %}
        {{ return(env_name) }}

    {% else %} {{ exceptions.raise_compiler_error("Unknown environment for host: " ~ host) }}
    {% endif %}
{% endmacro %}
