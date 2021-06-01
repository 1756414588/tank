package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetHeroPutInfoRq;
import com.game.server.GameServer;
import com.game.service.HeroService;

/**
 * @ClassName:GetHeroPutHandler
 * @author zc
 * @Description:获取文官入驻信息
 * @date 2017年7月4日
 */
public class GetHeroPutInfoHandler extends ClientHandler {

	@Override
	public void action() {
		GetHeroPutInfoRq req = msg.getExtension(GetHeroPutInfoRq.ext);
		GameServer.ac.getBean(HeroService.class).getHeroPutInfo(req, this);
	}

}
