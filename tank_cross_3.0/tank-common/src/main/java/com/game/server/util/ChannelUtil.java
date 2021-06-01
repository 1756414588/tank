/**
 * @Title: ChannelUtil.java @Package com.game.server.util @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月30日 下午12:04:52
 * @version V1.0
 */
package com.game.server.util;

import com.game.server.common.ChannelAttr;
import io.netty.channel.ChannelHandlerContext;
import io.netty.util.Attribute;
import org.apache.log4j.Logger;

import java.net.InetSocketAddress;

/**
 * @ClassName: ChannelUtil @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月30日 下午12:04:52
 */
public class ChannelUtil {
  private static Logger logger = Logger.getLogger("CHANNEL_CLOSE");

  public static void closeChannel(ChannelHandlerContext ctx, String reason) {
    logger.error(ctx + "-->close [because] " + reason);
    ctx.close();
  }

  public static Long getChannelId(ChannelHandlerContext ctx) {
    return ctx.attr(ChannelAttr.ID).get();
  }

  public static void setChannelId(ChannelHandlerContext ctx, Long id) {
    Attribute<Long> attribute = ctx.attr(ChannelAttr.ID);
    attribute.set(id);
  }

  public static Long createChannelId(ChannelHandlerContext ctx) {
    InetSocketAddress address = (InetSocketAddress) ctx.channel().remoteAddress();
    String ip = address.getAddress().getHostAddress();
    int port = address.getPort();
    Long id = ip2long(ip) * 100000L + port;
    return id;
  }

  public static void setRoleId(ChannelHandlerContext ctx, Long roleId) {
    Attribute<Long> attribute = ctx.attr(ChannelAttr.roleId);
    attribute.set(roleId);
  }

  public static void setServerId(ChannelHandlerContext ctx, int serverId) {
    Attribute<Integer> attribute = ctx.attr(ChannelAttr.serverId);
    attribute.set(serverId);
  }

  public static void setHeartTime(ChannelHandlerContext ctx, Long nowTime) {
    Attribute<Long> attribute = ctx.attr(ChannelAttr.heartTime);
    attribute.set(nowTime);
  }

  public static Long getRoleId(ChannelHandlerContext ctx) {
    return ctx.attr(ChannelAttr.roleId).get();
  }

  public static Integer getServerId(ChannelHandlerContext ctx) {
    return ctx.attr(ChannelAttr.serverId).get();
  }

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
        num =
            Long.parseLong(ips[0], 10) * 256L * 256L * 256L
                + Long.parseLong(ips[1], 10) * 256L * 256L
                + Long.parseLong(ips[2], 10) * 256L
                + Long.parseLong(ips[3], 10);
        num = num >>> 0;
      }
    } catch (NullPointerException ex) {
      System.out.println(ip);
    }

    return num;
  }
}
