{{ config(
    materialized = 'view'
) }}

WITH blocks AS (

    SELECT
        block_id,
        block_timestamp,
        block_hash,
        block_parent_hash,
        gas_limit,
        gas_used,
        miner,
        nonce,
        SIZE,
        tx_count,
        state_root,
        receipts_root
    FROM
        {{ ref('silver__blocks') }}
)
SELECT
    *
FROM
    blocks
