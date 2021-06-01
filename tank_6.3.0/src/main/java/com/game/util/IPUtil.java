
package com.game.util;

import org.apache.commons.lang3.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Enumeration;

public class IPUtil {
    private static final Logger logger = LoggerFactory.getLogger(IPUtil.class);

    // 获取局域网IP
    public static String getIP() {
        String ret = "";
        try {
            if (SystemUtils.IS_OS_LINUX) {
                Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces();
                while (en.hasMoreElements()) {
                    NetworkInterface ni = en.nextElement();
                    Enumeration<InetAddress> enIp = ni.getInetAddresses();
                    while (enIp.hasMoreElements()) {
                        InetAddress inet = enIp.nextElement();
                        if (inet.isSiteLocalAddress() && !inet.isLoopbackAddress() && (inet instanceof Inet4Address)) {
                            ret = inet.getHostAddress().toString();
                        }
                    }
                }
            } else {
                ret = InetAddress.getLocalHost().getHostAddress();
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
        return ret;
    }


    public static void main(String[] args) {
        String ipStr = getIP();
        System.out.println("IP：" + ipStr);
    }

}
