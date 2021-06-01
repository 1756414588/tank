/**
 * @Title: ChannelAttr.java @Package com.game.server.common @Description: TODO
 * @author ZhangJun
 * @date 2015年8月4日 下午3:01:25
 * @version V1.0
 */
package com.game.server.common;

import io.netty.util.AttributeKey;

/**
 * @ClassName: ChannelAttr @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月4日 下午3:01:25
 */
public class ChannelAttr {
    public static AttributeKey<Long> heartTime = AttributeKey.valueOf("heart");
    public static AttributeKey<Long> roleId = AttributeKey.valueOf("roleId");
    public static AttributeKey<Long> ID = AttributeKey.valueOf("ID");
    public static AttributeKey<Integer> serverId = AttributeKey.valueOf("serverId");
}
