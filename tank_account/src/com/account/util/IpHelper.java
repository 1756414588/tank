package com.account.util;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

import com.caucho.cloud.network.NetworkListenSystem;
import com.caucho.env.service.ResinSystem;
import com.caucho.network.listen.TcpPort;
import com.caucho.server.resin.Resin;

public class IpHelper {
    /**
     * 私有IP：A类 10.0.0.0-10.255.255.255 B类 172.16.0.0-172.31.255.255 C类
     * 192.168.0.0-192.168.255.255 当然，还有127这个网段是环回地址
     **/
    private static long A_BEGIN = getIpNum("10.0.0.0");
    private static long A_END = getIpNum("10.255.255.255");
    private static long B_BEGIN = getIpNum("172.16.0.0");
    private static long B_END = getIpNum("172.31.255.255");
    private static long C_BEGIN = getIpNum("192.168.0.0");
    private static long C_END = getIpNum("192.168.255.255");

    public static int getHttpPort() {
        PrintHelper.println("*****************http port*******************");
        Resin resin = Resin.getCurrent();
        ResinSystem resinSystem = resin.getResinSystem();
        NetworkListenSystem listenService = resinSystem.getService(NetworkListenSystem.class);
        for (TcpPort port : listenService.getListeners()) {
            if ("http".equals(port.getProtocolName())) {
                PrintHelper.println(port.getProtocolName() + " port:" + port.getPort());
                return port.getPort();
            }
        }
        return 0;
    }

    public static List<String> getAllIp() {
        List<String> ips = new ArrayList<>();
        Enumeration<NetworkInterface> interfaces = null;
        try {
            interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface ni = interfaces.nextElement();
                Enumeration<InetAddress> addresses = ni.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress addr = addresses.nextElement();
                    if (addr != null && addr instanceof Inet4Address) {
                        ips.add(addr.getHostAddress());
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return ips;
    }

    public static String getWireIp() {
        Enumeration<NetworkInterface> interfaces = null;
        try {
            interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface ni = interfaces.nextElement();
                Enumeration<InetAddress> addresses = ni.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress addr = addresses.nextElement();
                    if (addr != null && addr instanceof Inet4Address) {
                        String ip = addr.getHostAddress();
                        if (isWireIp(ip)) {
                            return ip;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public static String getLocalIp() {
        Enumeration<NetworkInterface> interfaces = null;
        try {
            interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface ni = interfaces.nextElement();
                Enumeration<InetAddress> addresses = ni.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress addr = addresses.nextElement();
                    if (addr != null && addr instanceof Inet4Address) {
                        String ip = addr.getHostAddress();
                        if (isInnerIP(ip, false)) {
                            return ip;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public static boolean isWireIp(String ipAddress) {
        return !isInnerIP(ipAddress, true);
    }

    public static boolean isInnerIP(String ipAddress, boolean includeLoopback) {
        boolean isInnerIp = false;
        long ipNum = getIpNum(ipAddress);

        if (includeLoopback) {
            isInnerIp = isInner(ipNum, A_BEGIN, A_END) || isInner(ipNum, B_BEGIN, B_END) || isInner(ipNum, C_BEGIN, C_END) || ipAddress.equals("127.0.0.1");
        } else {
            isInnerIp = isInner(ipNum, A_BEGIN, A_END) || isInner(ipNum, B_BEGIN, B_END) || isInner(ipNum, C_BEGIN, C_END);
        }

        return isInnerIp;
    }

    private static long getIpNum(String ipAddress) {
        String[] ip = ipAddress.split("\\.");
        long a = Integer.parseInt(ip[0]);
        long b = Integer.parseInt(ip[1]);
        long c = Integer.parseInt(ip[2]);
        long d = Integer.parseInt(ip[3]);

        long ipNum = a * 256 * 256 * 256 + b * 256 * 256 + c * 256 + d;
        return ipNum;
    }

    private static boolean isInner(long userIp, long begin, long end) {
        return (userIp >= begin) && (userIp <= end);
    }
}
