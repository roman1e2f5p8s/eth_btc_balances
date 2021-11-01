DECLARE START_DATE DATE DEFAULT DATE("2015-06-01");
--DECLARE END_DATE DATE DEFAULT DATE("2015-08-01");
DECLARE END_DATE DATE DEFAULT DATE_TRUNC(CURRENT_DATE(), MONTH);
DECLARE DATE_ DATE;
DECLARE QUERY STRING DEFAULT "SELECT * FROM ";

SET DATE_ = DATE_ADD(START_DATE, INTERVAL 1 MONTH);

SET QUERY = QUERY || """(SELECT ROW_NUMBER() OVER(ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC) AS rank_, """;
SET QUERY = QUERY || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY));
SET QUERY = QUERY || """ FROM(WITH double_entry_book AS (select to_address as address, value as value from `bigquery-public-data.crypto_ethereum.traces`""";
SET QUERY = QUERY || """ where to_address is not null and status = 1 and value > 0 and date(block_timestamp) < '""" || FORMAT_DATE("%Y-%m-%d", DATE_);
SET QUERY = QUERY || """' and (call_type not in ('delegatecall', 'callcode', 'staticcall') or call_type is null) union all""";
SET QUERY = QUERY || """ select from_address as address, -value as value from `bigquery-public-data.crypto_ethereum.traces` where from_address is not null""";
SET QUERY = QUERY || """ and status = 1 and value > 0 and date(block_timestamp) < '""" || FORMAT_DATE("%Y-%m-%d", DATE_);
SET QUERY = QUERY || """' and (call_type not in ('delegatecall', 'callcode', 'staticcall') or call_type is null) union all""";
SET QUERY = QUERY || """ select miner as address, sum(cast(receipt_gas_used as numeric) * cast((receipt_effective_gas_price - coalesce(base_fee_per_gas, 0)) as numeric)) as value""";
SET QUERY = QUERY || """ from `bigquery-public-data.crypto_ethereum.transactions` as transactions join `bigquery-public-data.crypto_ethereum.blocks` as blocks on blocks.number = transactions.block_number""";
SET QUERY = QUERY || """ group by blocks.miner union all select from_address as address, -(cast(receipt_gas_used as numeric) * cast(gas_price as numeric)) as value""";
SET QUERY = QUERY || """ from `bigquery-public-data.crypto_ethereum.transactions`) SELECT sum(value) / POWER(10, 18) as """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY));
SET QUERY = QUERY || """ FROM double_entry_book GROUP BY address ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC LIMIT 100)""";
SET QUERY = QUERY || """ ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC)""";

SET DATE_ = DATE_ADD(DATE_, INTERVAL 1 MONTH);

WHILE DATE_ <= END_DATE DO
    SET QUERY = QUERY || """ INNER JOIN (SELECT ROW_NUMBER() OVER(ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC) AS rank_, """;
    SET QUERY = QUERY || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY));
    SET QUERY = QUERY || """ FROM(WITH double_entry_book AS (select to_address as address, value as value from `bigquery-public-data.crypto_ethereum.traces`""";
    SET QUERY = QUERY || """ where to_address is not null and status = 1 and value > 0 and date(block_timestamp) < '""" || FORMAT_DATE("%Y-%m-%d", DATE_);
    SET QUERY = QUERY || """' and (call_type not in ('delegatecall', 'callcode', 'staticcall') or call_type is null) union all""";
    SET QUERY = QUERY || """ select from_address as address, -value as value from `bigquery-public-data.crypto_ethereum.traces` where from_address is not null""";
    SET QUERY = QUERY || """ and status = 1 and value > 0 and date(block_timestamp) < '""" || FORMAT_DATE("%Y-%m-%d", DATE_);
    SET QUERY = QUERY || """' and (call_type not in ('delegatecall', 'callcode', 'staticcall') or call_type is null) union all""";
    SET QUERY = QUERY || """ select miner as address, sum(cast(receipt_gas_used as numeric) * cast((receipt_effective_gas_price - coalesce(base_fee_per_gas, 0)) as numeric)) as value""";
    SET QUERY = QUERY || """ from `bigquery-public-data.crypto_ethereum.transactions` as transactions join `bigquery-public-data.crypto_ethereum.blocks` as blocks on blocks.number = transactions.block_number""";
    SET QUERY = QUERY || """ group by blocks.miner union all select from_address as address, -(cast(receipt_gas_used as numeric) * cast(gas_price as numeric)) as value""";
    SET QUERY = QUERY || """ from `bigquery-public-data.crypto_ethereum.transactions`) SELECT sum(value) / POWER(10, 18) as """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY));
    SET QUERY = QUERY || """ FROM double_entry_book GROUP BY address ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC LIMIT 100)""";
    SET QUERY = QUERY || """ ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC) USING(rank_)""";

  SET DATE_ = DATE_ADD(DATE_, INTERVAL 1 MONTH);
END WHILE;

SET QUERY = QUERY || """ORDER BY rank_ ASC""";

EXECUTE IMMEDIATE QUERY; 
