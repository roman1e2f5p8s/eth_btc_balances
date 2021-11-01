import pandas as pd
from google.cloud import bigquery

date = '2012-10-29'

client = bigquery.Client()

query = """
WITH double_entry_book AS (
   -- debits
   SELECT array_to_string(inputs.addresses, ",") as address, -inputs.value as value
   FROM `bigquery-public-data.crypto_bitcoin.inputs` as inputs
   WHERE inputs.value > 0 AND DATE(inputs.block_timestamp) < \'{}\'
   UNION ALL
   -- credits
   SELECT array_to_string(outputs.addresses, ",") as address, outputs.value as value
   FROM `bigquery-public-data.crypto_bitcoin.outputs` as outputs
   WHERE outputs.value > 0 AND DATE(outputs.block_timestamp) < \'{}\'
)
SELECT sum(value) as balance
FROM double_entry_book
GROUP BY address
ORDER BY balance DESC
LIMIT 10
""".format(date, date)

query_job = client.query(query)
iterator = query_job.result(timeout=60)
df = iterator.to_dataframe()
