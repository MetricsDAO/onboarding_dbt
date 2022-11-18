{{ config(
    materialized = 'view'
) }}

WITH transfers AS (

    SELECT
        log_id,
        block_id,
        tx_hash,
        block_timestamp,
        contract_address,
        from_address,
        to_address,
        raw_amount
    FROM
        {{ ref('silver__transfers') }}
)
SELECT
    *
FROM
    transfers
