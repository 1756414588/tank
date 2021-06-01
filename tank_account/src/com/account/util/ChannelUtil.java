package com.account.util;

import io.netty.channel.ChannelHandlerContext;
import io.netty.util.Attribute;
import io.netty.util.AttributeKey;

import java.net.InetSocketAddress;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author ZhangJun
 * @ClassName: ChannelUtil
 * @Description: TODO
 * @date 2015年7月30日 下午12:04:52
 */
public class ChannelUtil {

    public static Logger LOG = LoggerFactory.getLogger(ChannelUtil.class);
    public static AttributeKey<Long> ID = AttributeKey.valueOf("ID");
    private static Logger logger = LoggerFactory.getLogger("CHANNEL_CLOSE");

    public static void closeChannel(ChannelHandlerContext ctx, String reason) {
        logger.error(ctx + "-->close [because] " + reason);
        ctx.close();
    }

    public static Long getChannelId(ChannelHandlerContext ctx) {
        return ctx.attr(ID).get();
    }

    public static Long createChannelId(ChannelHandlerContext ctx) {
        InetSocketAddress address = (InetSocketAddress) ctx.channel().remoteAddress();
        String ip = address.getAddress().getHostAddress();
        int port = address.getPort();
        Long id = ip2long(ip) * 100000L + port;
        return id;
    }

    public static void setChannelId(ChannelHandlerContext ctx, Long id) {
        Attribute<Long> attribute = ctx.attr(ID);
        attribute.set(id);
    }

    /**
     * IP转成整型
     *
     * @param ip
     * @return
     */
    private static Long ip2long(String ip) {
        Long num = 0L;
        if (ip == null) {
            return num;
        }

        try {
            ip = ip.replaceAll("[^0-9\\.]", ""); // 去除字符串前的空字符
            String[] ips = ip.split("\\.");
            if (ips.length == 4) {
                num = Long.parseLong(ips[0], 10) * 256L * 256L * 256L + Long.parseLong(ips[1], 10) * 256L * 256L + Long.parseLong(ips[2], 10) * 256L
                        + Long.parseLong(ips[3], 10);
                num = num >>> 0;
            }
        } catch (NullPointerException ex) {
            LOG.error(ip);
        }

        return num;
    }
}
