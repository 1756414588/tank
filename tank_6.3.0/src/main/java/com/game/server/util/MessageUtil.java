/**   
 * @Title: MessageUtil.java    
 * @Package com.game.server.util    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午7:00:49    
 * @version V1.0   
 */
package com.game.server.util;

import com.game.pb.BasePb.Base;
import io.netty.channel.ChannelHandlerContext;

/**
 * @ClassName: MessageUtil
 * @Description:  消息处理工具类
 * @author ZhangJun
 * @date 2015年7月29日 下午7:00:49
 * 
 */
public class MessageUtil {
    
    /**
     * 
    * @Title: writeToPlayer 
    * @Description: 发送指定协议消息给玩家
    * @param ctx
    * @param msg  
    * void   

     */
	public static void writeToPlayer(ChannelHandlerContext ctx, Base msg) {	        
		ctx.channel().writeAndFlush(msg);
	}
}
