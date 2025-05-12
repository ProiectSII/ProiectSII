package org.spark.service.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OracleDataLoader {

    @Value("${spark.jdbc.url}")
    private String url;

    @Value("${spark.jdbc.user}")
    private String user;

    @Value("${spark.jdbc.password}")
    private String password;

    @Value("${spark.jdbc.driver}")
    private String driver;

    private final SparkSessionFactory sparkSessionFactory;

    public Dataset<Row> loadTableOrView(String dbTableOrViewName) {
        return sparkSessionFactory.getSparkSession()
                .read()
                .format("jdbc")
                .option("url", url)
                .option("dbtable", dbTableOrViewName)
                .option("user", user)
                .option("password", password)
                .option("driver", driver)
                .load();
    }
}
