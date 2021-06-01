package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.PropService;

/**
 * UseSkinHandler
 * @author zc
 * @Description:使用外观
 * @date 2017年8月2日
 */
public class UseSkinHandler extends ClientHandler {

	@Override
	public void action() {
		GamePb6.UseSkinRq req = msg.getExtension(GamePb6.UseSkinRq.ext);
		GameServer.ac.getBean(PropService.class).useSkin(req, this);
	}

}
