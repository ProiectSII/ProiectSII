package org.spark.service.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@ConfigurationProperties(prefix = "spark")
@Component
@Getter
@Setter
public class SparkProperties {

    private String master;
    private boolean hiveSupport;
    private final App app = new App();
    private final Thrift thrift = new Thrift();

    @Getter @Setter
    public static class App {
        private String name;
    }

    @Getter @Setter
    public static class Thrift {
        private String port;
    }
}
