{{ config (
    materialized = 'view'
) }}
{# 
    Bronze level is a view on the source so in silver we can just use the ref function.
 #}
SELECT
    record_id,
    tx_id,
    tx_block_index,
    offset_id,
    block_id,
    block_timestamp,
    network,
    chain_id,
    tx,
    _inserted_timestamp
FROM
    {{ source(
        "chainwalkers",
        "harmony_txs"
    ) }}
WHERE
    block_timestamp :: DATE BETWEEN '2022-01-01'
    AND '2022-03-31'
