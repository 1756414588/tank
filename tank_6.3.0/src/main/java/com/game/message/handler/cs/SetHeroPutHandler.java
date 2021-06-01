package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.SetHeroPutRq;
import com.game.server.GameServer;
import com.game.service.HeroService;

/**
 * @ClassName:SetHeroPutHandler
 * @author zc
 * @Description:设置文官入驻
 * @date 2017年7月4日
 */
public class SetHeroPutHandler extends ClientHandler {

	/* (non-Javadoc)
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		SetHeroPutRq req = msg.getExtension(SetHeroPutRq.ext);
		GameServer.ac.getBean(HeroService.class).setHeroPut(req, this);
	}

}
