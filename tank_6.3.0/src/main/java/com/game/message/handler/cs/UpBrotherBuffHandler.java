package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @ClassName:UpBrotherBuffHandler
 * @author zc
 * @Description:升级飞艇buff
 * @date 2017年9月11日
 */
public class UpBrotherBuffHandler extends ClientHandler {

	@Override
	public void action() {
		GamePb6.UpBrotherBuffRq req = msg.getExtension(GamePb6.UpBrotherBuffRq.ext);
		GameServer.ac.getBean(ActionCenterService.class).upBrotherBuff(req.getBuffType(), this);
	}
}
