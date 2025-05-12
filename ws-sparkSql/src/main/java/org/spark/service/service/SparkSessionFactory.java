package org.spark.service.service;

import lombok.Getter;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.hive.thriftserver.HiveThriftServer2;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.spark.service.config.SparkProperties;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

@Component
public class SparkSessionFactory {

    private static final Logger logger = LoggerFactory.getLogger(SparkSessionFactory.class);
    private final SparkProperties sparkProperties;
    @Getter
    private SparkSession sparkSession;

    public SparkSessionFactory(SparkProperties sparkProperties) {
        this.sparkProperties = sparkProperties;
        initializeSession();
    }

    private void initializeSession() {
        SparkSession.Builder builder = SparkSession.builder()
                .appName(sparkProperties.getApp().getName())
                .master(sparkProperties.getMaster());

        if (sparkProperties.isHiveSupport()) {
            builder.enableHiveSupport()
                    .config("spark.sql.hive.thriftServer.singleSession", true)
                    .config("hive.server2.thrift.port", sparkProperties.getThrift().getPort());
        }

        sparkSession = builder.getOrCreate();
        logger.info("SparkSession initialized with Hive support = {}", sparkProperties.isHiveSupport());
    }

    @PostConstruct
    public void start() {
        HiveThriftServer2.startWithContext(getSparkSession().sqlContext());
    }

    @PreDestroy
    public void shutdown() {
        if (sparkSession != null) {
            sparkSession.stop();
            logger.info("SparkSession stopped.");
        }
    }
}
