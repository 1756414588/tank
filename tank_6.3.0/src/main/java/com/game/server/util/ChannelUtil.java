/**
 * @Title: ChannelUtil.java
 * @Package com.game.server.util
 * @Description:
 * @author ZhangJun
 * @date 2015年7月30日 下午12:04:52
 * @version V1.0
 */
package com.game.server.util;

import com.game.server.common.ChannelAttr;
import com.game.util.LogUtil;
import io.netty.channel.Channel;
import io.netty.channel.ChannelHandlerContext;
import io.netty.util.Attribute;
import org.apache.log4j.Logger;

import java.net.InetSocketAddress;

/**
 * @ClassName: ChannelUtil
 * @Description: ChannelHandlerContext  接连相关处理的工具类 * @author ZhangJun
 * @date 2015年7月30日 下午12:04:52
 *
 */
public class ChannelUtil {
    private static Logger logger = Logger.getLogger("CHANNEL_CLOSE");

    /**
     *
     * @Title: closeChannel
     * @Description: 断开一个连接
     * @param ctx
     * @param reason
     * void

     */
    public static void closeChannel(ChannelHandlerContext ctx, String reason) {
        LogUtil.channel(ctx + "-->close [because] " + reason);
        ctx.close();
    }

    /**
     *
     * @Title: getChannelId
     * @Description: 得到连接编号
     * @param ctx
     * @return
     * Long

     */
    public static Long getChannelId(ChannelHandlerContext ctx) {
        return ctx.attr(ChannelAttr.ID).get();
    }

    /**
     *
     * @Title: setChannelId
     * @Description: 设置连接编号
     * @param ctx
     * @param id
     * void

     */
    public static void setChannelId(ChannelHandlerContext ctx, Long id) {
        Attribute<Long> attribute = ctx.attr(ChannelAttr.ID);
        attribute.set(id);
    }

    /**
     *
     * @Title: createChannelId
     * @Description: 根据客户端ip和端口产生连接编号
     * @param ctx
     * @return
     * Long

     */
    public static Long createChannelId(ChannelHandlerContext ctx) {
        InetSocketAddress address = (InetSocketAddress) ctx.channel().remoteAddress();
        String ip = address.getAddress().getHostAddress();
        int port = address.getPort();
        Long id = ip2long(ip) * 100000L + port;
        return id;
    }

    /**
     *
     * @Title: setRoleId
     * @Description: 设置连接对应的角色编号
     * @param ctx
     * @param roleId
     * void

     */
    public static void setRoleId(ChannelHandlerContext ctx, Long roleId) {
        Attribute<Long> attribute = ctx.attr(ChannelAttr.roleId);
        attribute.set(roleId);
    }


    public static String getIp(ChannelHandlerContext ctx, long roleId) {
        try {
            Channel channel = ctx != null ? ctx.channel() : null;
            InetSocketAddress address = (InetSocketAddress) (channel != null ? ctx.channel().remoteAddress() : null);
            return address != null ? address.getAddress().getHostAddress() : null;
        } catch (Exception e) {
            LogUtil.error("获取玩家IP出错, roleId:" + roleId, e);
            return "";
        }
    }


    /**
     *
     * @Title: setHeartTime
     * @Description: 设置心跳时间
     * @param ctx
     * @param nowTime
     * void

     */
    public static void setHeartTime(ChannelHandlerContext ctx, Long nowTime) {
        Attribute<Long> attribute = ctx.attr(ChannelAttr.heartTime);
        attribute.set(nowTime);
    }

    /**
     *
     * @Title: getRoleId
     * @Description: 获得ChannelHandlerContext的角色编号
     * @param ctx
     * @return
     * Long

     */

    public static Long getRoleId(ChannelHandlerContext ctx) {
        return ctx.attr(ChannelAttr.roleId).get();
    }

    /**
     *
     * @Title: getHeartTime
     * @Description: 获得ChannelHandlerContext的心跳时间
     * @param ctx
     * @return
     * Long

     */
    public static Long getHeartTime(ChannelHandlerContext ctx) {
        return ctx.attr(ChannelAttr.heartTime).get();
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
                num = Long.parseLong(ips[0], 10) * 256L * 256L * 256L + Long.parseLong(ips[1], 10) * 256L * 256L
                        + Long.parseLong(ips[2], 10) * 256L + Long.parseLong(ips[3], 10);
                num = num >>> 0;
            }
        } catch (NullPointerException ex) {
            LogUtil.info(ip);
        }

        return num;
    }
}
