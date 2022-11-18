{{ config(
    materialized = 'incremental',
    unique_key = 'block_id',
    cluster_by = ['_inserted_timestamp']
) }}

WITH base_blocks AS (

    SELECT
        *
    FROM
        {{ ref("bronze__blocks") }}
    WHERE
    {# 
        We only want to load the newest data. As the source is not updating, in this example project, this will never grab new data on an incremental run.
        If our command is `dbt run --full-refresh` then the code inside the incremental load filter will not run.
        This is a macro - see what the SQL code is in: macros/incremental_utils.sql
     #}
        {{ incremental_load_filter("_inserted_timestamp") }}
    {# 
        Here, we are de-duplicating the data. Chainwalkers might get the same block or transaction multiple times.
        This approach presumes the most recent one is the correct piece of data.
    #}
        qualify ROW_NUMBER() over (
            PARTITION BY block_id
            ORDER BY
                _inserted_timestamp DESC
        ) = 1
),
FINAL AS (
    SELECT
        block_id,
        block_timestamp,
        header :hash :: STRING AS block_hash,
        header :parent_hash :: STRING AS block_parent_hash,
        header :gas_limit AS gas_limit,
        header :gas_used AS gas_used,
        header :miner :: STRING AS miner,
        header :nonce :: STRING AS nonce,
        header :size AS SIZE,
        tx_count,
        header :state_root :: STRING AS state_root,
        header :receipts_root :: STRING AS receipts_root,
        _inserted_timestamp
    FROM
        base_blocks
)
SELECT
    *
FROM
    FINAL
