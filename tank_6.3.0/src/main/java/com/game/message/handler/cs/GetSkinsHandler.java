package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.PropService;

/**
 * @ClassName:GetSkinsHandler
 * @author zc
 * @Description:获取皮肤
 * @date 2017年7月19日
 */
public class GetSkinsHandler extends ClientHandler {
	@Override
	public void action() {
	    GamePb6.GetSkinsRq req = msg.getExtension(GamePb6.GetSkinsRq.ext);
		GameServer.ac.getBean(PropService.class).getSkins(req, this);
	}

}
