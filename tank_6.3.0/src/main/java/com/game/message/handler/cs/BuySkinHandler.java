package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.PropService;

/**
 * @ClassName:BuySkinRankHandler
 * @author zc
 * @Description:购买外观
 * @date 2017年7月19日
 */
public class BuySkinHandler extends ClientHandler {
	@Override
	public void action() {
		GamePb6.BuySkinRq req = msg.getExtension(GamePb6.BuySkinRq.ext);
		GameServer.ac.getBean(PropService.class).buySkin(req, this);
	}

}
