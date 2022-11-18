{{ config(
    materialized = 'view'
) }}

WITH logs AS (

    SELECT
        log_id,
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
        event_removed
    FROM
        {{ ref('silver__logs') }}
)
SELECT
    *
FROM
    logs
