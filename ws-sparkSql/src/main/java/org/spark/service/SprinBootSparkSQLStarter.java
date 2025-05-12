package org.spark.service;

import org.spark.service.config.SparkProperties;
import org.spark.service.service.SparkSessionFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

import java.util.logging.Logger;

@SpringBootApplication(exclude={DataSourceAutoConfiguration.class} )
public class SprinBootSparkSQLStarter extends SpringBootServletInitializer {
//        private static final Logger logger = Logger.getLogger(SprinBootSparkSQLStarter.class.getName());

        public static void main(String[] args) {
//            logger.info("Loading ... SparkStarterService with Spark Default Settings ... DSA");
            SpringApplication.run(SprinBootSparkSQLStarter.class, args);
        }

}
