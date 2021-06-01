/**   
 * @Title: IServer.java    
 * @Package com.game.server    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午3:07:08    
 * @version V1.0   
 */
package com.game.server;

import com.game.pb.BasePb.Base;
import io.netty.channel.ChannelHandlerContext;

/**
 * @ClassName: 服务器接口 没用到
 * @Description: 
 * @author ZhangJun
 * @date 2015年7月29日 下午3:07:08
 * 
 */
public interface IServer {
	/**
	 * 
	 * Method: doCommand
	 * 
	 * @Description: 处理消息
	 * @param paramIoSession
	 * @param msg
	 * @return void

	 */
	public abstract void doCommand(ChannelHandlerContext ctx, Base msg);

	/**
	 * 
	 * Method: channelActive
	 * 
	 * @Description: channel 打开
	 * @param ctx
	 * @return void

	 */
	public void channelActive(ChannelHandlerContext ctx);

	/**
	 * 
	 * Method: channelInactive
	 * 
	 * @Description: channel 关闭
	 * @param ctx
	 * @return void

	 */
	public void channelInactive(ChannelHandlerContext ctx);
}
