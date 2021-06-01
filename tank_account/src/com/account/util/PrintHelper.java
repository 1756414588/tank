package com.account.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PrintHelper {
    public static Logger LOG = LoggerFactory.getLogger(PrintHelper.class);
    public static final boolean ENABALE = true;

    static public void println(String x) {
        if (ENABALE) {
            LOG.error(x);
        }
    }
}
