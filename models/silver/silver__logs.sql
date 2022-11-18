{{ config(
    materialized = 'incremental',
    unique_key = 'log_id',
    cluster_by = ['_inserted_timestamp']
) }}

WITH base_txs AS (

    SELECT
        *
    FROM
        {{ ref("silver__transactions") }}
    WHERE
    {# 
        Similarly, we want to load incrementally, whenever possible. 
        There is no need to de-duplicate because the logs are now downstream of silver transactions, 
            which has already done this.
     #}
        {{ incremental_load_filter("_inserted_timestamp") }}
),
logs_raw AS (
    SELECT
        block_id,
        block_timestamp,
        _inserted_timestamp,
        tx_hash,
        tx_receipt :logs AS full_logs
    FROM
        base_txs
),
logs AS (
    SELECT
        block_id,
        block_timestamp,
        _inserted_timestamp,
        tx_hash,
        VALUE :logIndex :: STRING AS event_index,
        VALUE :bech32_address :: STRING AS native_contract_address,
        VALUE :address :: STRING AS evm_contract_address,
        VALUE :decoded :contractName :: STRING AS contract_name,
        VALUE :decoded :eventName :: STRING AS event_name,
        VALUE :decoded :inputs AS event_inputs,
        VALUE :topics AS topics,
        VALUE :data :: STRING AS DATA,
        VALUE :removed AS event_removed
    FROM
        logs_raw,
        LATERAL FLATTEN (
            input => full_logs
        )
),
FINAL AS (
    SELECT
        concat_ws(
            '-',
            tx_hash,
            event_index
        ) AS log_id,
        block_id,
        block_timestamp,
        tx_hash,
        event_index,
        native_contract_address,
        evm_contract_address,
        contract_name,
        event_name,
        event_inputs,
        topics,
        DATA,
        event_removed,
        _inserted_timestamp
    FROM
        logs
)
SELECT
    *
FROM
    FINAL
