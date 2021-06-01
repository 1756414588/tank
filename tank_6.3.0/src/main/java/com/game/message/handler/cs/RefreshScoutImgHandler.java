package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.WorldService;

/**
* @author: LiFeng
* @date:2018年9月20日 上午11:33:47
* @description:
*/
public class RefreshScoutImgHandler extends ClientHandler {

	@Override
	public void action() {
		getService(WorldService.class).refreshScoutImg(msg.getExtension(GamePb6.RefreshScoutImgRq.ext), this);
	}

}
