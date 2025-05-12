package org.spark.service.rest;

import lombok.RequiredArgsConstructor;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.spark.service.service.OracleDataLoader;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.logging.Logger;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AggregationController {
    private static final Logger logger = Logger.getLogger(AggregationController.class.getName());
    private final OracleDataLoader service;

    @RequestMapping(value = "/ping", method = RequestMethod.GET, produces = {MediaType.TEXT_PLAIN_VALUE})
    @ResponseBody
    public String pingDataSource() {
        logger.info(">>>> SparkSQLRESTService is Up!");
        return "PING response from SparkSQLRESTService!";
    }

    @RequestMapping(value = "/view/{VIEW_NAME}", method = RequestMethod.GET,
            produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.TEXT_PLAIN_VALUE})
    @ResponseBody
    public String getViewDataSet(@PathVariable("VIEW_NAME") String viewName) {
        logger.info("DEBUG: getViewDataSet: Querying View: " + viewName);
        Dataset<Row> viewDataSet = service.loadTableOrView(viewName);
        logger.info("DEBUG: getViewDataSet: View Schema: ");
        viewDataSet.printSchema();
        logger.info("DEBUG: get_ViewDataSet: View Data: ");
        viewDataSet.show();

        return viewDataSet.toJSON().collectAsList().toString();
    }
}