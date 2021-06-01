package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @ClassName:GetActChooseGiftHandler
 * @author zc
 * @Description:进入自选豪礼页面
 * @date 2017年8月25日
 */
public class GetActChooseGiftHandler extends ClientHandler {

	@Override
	public void action() {
		GameServer.ac.getBean(ActionCenterService.class).getActChooseGift(this);
	}

}
