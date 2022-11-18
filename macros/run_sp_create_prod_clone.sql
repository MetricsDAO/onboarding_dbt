{% macro run_sp_create_prod_clone() %}
    {% set clone_query %}
    call onboarding._internal.create_prod_clone(
        'onboarding',
        'onboarding_dev',
        'dbt_cloud'
    );
{% endset %}
    {% do run_query(clone_query) %}
{% endmacro %}