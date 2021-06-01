/**   
 * @Title: VerifyRsHandler.java    
 * @Package com.game.message.handler.ss    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月3日 下午6:56:13    
 * @version V1.0   
 */
package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.GamePb1.BeginGameRs;
import com.game.pb.InnerPb.VerifyRs;
import com.game.server.GameServer;
import com.game.server.work.WWork;
import com.game.service.PlayerService;
import io.netty.channel.ChannelHandlerContext;

/**
 * @ClassName: VerifyRsHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月3日 下午6:56:13
 * 
 */
public class VerifyRsHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		VerifyRs req = msg.getExtension(VerifyRs.ext);
		GameServer gameServer = GameServer.getInstance();
		Long channelId = req.getChannelId();
//		LogUtil.info("verify rs handler channelid : " + channelId);
		ChannelHandlerContext ctx = gameServer.userChannels.get(channelId);
		
		if (ctx == null) {
			return;
		}

		if (msg.getCode() != 200) {
			Base.Builder builder = Base.newBuilder();
			builder.setCmd(BeginGameRs.EXT_FIELD_NUMBER);
			builder.setCode(msg.getCode());
			gameServer.connectServer.sendExcutor.addTask(channelId, new WWork(ctx, builder.build()));
			return;
		}

		PlayerService playerService = GameServer.ac.getBean(PlayerService.class);
		playerService.verifyRs(req, this, ctx);
	}
}
