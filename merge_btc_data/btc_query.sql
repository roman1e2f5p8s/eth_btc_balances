DECLARE START_DATE DATE DEFAULT DATE("2009-01-01");
--DECLARE END_DATE DATE DEFAULT DATE("2019-01-01");
DECLARE END_DATE DATE DEFAULT DATE_TRUNC(CURRENT_DATE(), MONTH);
DECLARE DATE_ DATE;
DECLARE QUERY STRING DEFAULT "SELECT * FROM ";

SET DATE_ = DATE_ADD(START_DATE, INTERVAL 1 MONTH);

SET QUERY = QUERY || """(SELECT ROW_NUMBER() OVER(ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC) AS rank_, """;
SET QUERY = QUERY || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY));
SET QUERY = QUERY || """ FROM(WITH double_entry_book AS (SELECT array_to_string(inputs.addresses, ",") as address, -inputs.value as value """;
SET QUERY = QUERY || """FROM `bigquery-public-data.crypto_bitcoin.inputs` as inputs WHERE inputs.value > 0 AND DATE(inputs.block_timestamp) < '""";
SET QUERY = QUERY || FORMAT_DATE("%Y-%m-%d", DATE_) || """' UNION ALL SELECT array_to_string(outputs.addresses, ",") as address, outputs.value as value """;
SET QUERY = QUERY || """FROM `bigquery-public-data.crypto_bitcoin.outputs` as outputs WHERE outputs.value > 0 AND DATE(outputs.block_timestamp) < '""";
SET QUERY = QUERY || FORMAT_DATE("%Y-%m-%d", DATE_) || """') SELECT sum(value) / POWER(10, 8) as """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY));
SET QUERY = QUERY || """ FROM double_entry_book GROUP BY address ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC LIMIT 100)""";
SET QUERY = QUERY || """ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC)""";

SET DATE_ = DATE_ADD(DATE_, INTERVAL 1 MONTH);

WHILE DATE_ <= END_DATE DO
  SET QUERY = QUERY || """ INNER JOIN (SELECT ROW_NUMBER() OVER(ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC) AS rank_, """;
  SET QUERY = QUERY || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY));
  SET QUERY = QUERY || """ FROM(WITH double_entry_book AS (SELECT array_to_string(inputs.addresses, ",") as address, -inputs.value as value """;
  SET QUERY = QUERY || """FROM `bigquery-public-data.crypto_bitcoin.inputs` as inputs WHERE inputs.value > 0 AND DATE(inputs.block_timestamp) < '""";
  SET QUERY = QUERY || FORMAT_DATE("%Y-%m-%d", DATE_) || """' UNION ALL SELECT array_to_string(outputs.addresses, ",") as address, outputs.value as value """;
  SET QUERY = QUERY || """FROM `bigquery-public-data.crypto_bitcoin.outputs` as outputs WHERE outputs.value > 0 AND DATE(outputs.block_timestamp) < '""";
  SET QUERY = QUERY || FORMAT_DATE("%Y-%m-%d", DATE_) || """') SELECT sum(value) / POWER(10, 8) as """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY));
  SET QUERY = QUERY || """ FROM double_entry_book GROUP BY address ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC LIMIT 100)""";
  SET QUERY = QUERY || """ORDER BY """ || FORMAT_DATE("d%Y_%m_%d", DATE_SUB(DATE_, INTERVAL 1 DAY)) || """ DESC) USING(rank_)""";

  SET DATE_ = DATE_ADD(DATE_, INTERVAL 1 MONTH);
END WHILE;

SET QUERY = QUERY || """ORDER BY rank_ ASC""";

EXECUTE IMMEDIATE QUERY; 
