/**   
 * @Title: RWork.java    
 * @Package com.game.server.work    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月3日 下午6:16:23    
 * @version V1.0   
 */
package com.game.server.work;

import com.game.message.handler.InnerHandler;
import com.game.pb.BasePb.Base;
import com.game.server.GameServer;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;

/**
 * IRWork  和跨服服务器通信并执行的相关逻辑的指令
 * @author wanyi
 *
 */
public class IRWork extends AbstractWork {
	private ChannelHandlerContext ctx;
	private Base msg;

	public IRWork(ChannelHandlerContext ctx, Base msg) {
		this.ctx = ctx;
		this.msg = msg;
	}

    /**
     * 
    * <p>Title: run</p> 
    * <p>Description: 执行任务</p>  
    * @see java.lang.Runnable#run()
     */
	@Override
	public void run() {
		try {
			GameServer gameServer = GameServer.getInstance();
			int cmd = msg.getCmd();
			InnerHandler handler = gameServer.messagePool.getInnerHandler(cmd);
			if (handler == null) {
				return;
			}

			handler.setCtx(ctx);
			handler.setMsg(msg);

			gameServer.mainLogicServer.addCommand(handler);

		} catch (Exception e) {
			LogUtil.error("执行内部通讯出错", e);
		}

	}
}
