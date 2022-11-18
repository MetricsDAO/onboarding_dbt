{{ config (
    materialized = 'view'
) }}
{#
bronze LEVEL IS A VIEW
ON THE source so IN silver we can just USE THE ref FUNCTION.#}

SELECT
    record_id,
    offset_id,
    block_id,
    block_timestamp,
    network,
    chain_id,
    tx_count,
    header,
    _inserted_timestamp
FROM
    {{ source(
        "chainwalkers",
        "harmony_blocks"
    ) }}
WHERE
    block_timestamp :: DATE BETWEEN '2022-01-01'
    AND '2022-03-31'
