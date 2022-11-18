{{ config(
    materialized = 'view'
) }}

WITH txs AS (

    SELECT
        block_timestamp,
        block_id,
        tx_hash,
        nonce,
        INDEX,
        native_from_address,
        native_to_address,
        from_address,
        to_address,
        VALUE,
        block_number,
        block_hash,
        gas_price,
        gas_limit,
        DATA,
        status,
        tx_receipt
    FROM
        {{ ref('silver__transactions') }}
)
SELECT
    *
FROM
    txs
