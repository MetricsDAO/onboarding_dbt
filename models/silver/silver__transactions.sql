{{ config(
    materialized = 'incremental',
    unique_key = 'tx_hash',
    cluster_by = ['_inserted_timestamp']
) }}

WITH base_txs AS (

    SELECT
        *
    FROM
        {{ ref("bronze__transactions") }}
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
        block_timestamp,
        block_id,
        tx_id AS tx_hash,
        tx :nonce :: STRING AS nonce,
        tx_block_index AS INDEX,
        tx :bech32_from :: STRING AS native_from_address,
        tx :bech32_to :: STRING AS native_to_address,
        tx :from :: STRING AS from_address,
        tx :to :: STRING AS to_address,
        tx :value AS VALUE,
        tx :block_number AS block_number,
        tx :block_hash :: STRING AS block_hash,
        tx :gas_price AS gas_price,
        tx :gas AS gas_limit,
        tx :input :: STRING AS DATA,
        tx :receipt :status :: STRING = '0x1' AS status,
        tx: receipt as tx_receipt,
        _inserted_timestamp
    FROM
        base_txs
)
SELECT
    *
FROM
    FINAL
