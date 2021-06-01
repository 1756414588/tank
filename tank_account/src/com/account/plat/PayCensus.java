package com.account.plat;

import java.io.IOException;
import java.util.Properties;

import javax.annotation.PostConstruct;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PropertiesLoaderUtils;
import org.springframework.stereotype.Component;

/**
 * @author ChenKui
 * @version 创建时间：2016-5-21 上午11:32:30
 * @declare
 */
public class PayCensus {

    private String CENSUS_URL;
    private String APP_ID;

    private Properties loadProperties(String path, String name) {
        try {
            Resource resource = new ClassPathResource(path + name);
            Properties properties = PropertiesLoaderUtils.loadProperties(resource);
            return properties;
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

    public void init() {
        Properties properties = loadProperties("com/account/plat", "census.properties");

        CENSUS_URL = properties.getProperty("CENSUS_URL");
        APP_ID = properties.getProperty("APP_ID");
    }

    /**
     * 同步统计
     *
     * @param param
     */
    public static void payCensus(String... param) {


    }

}
