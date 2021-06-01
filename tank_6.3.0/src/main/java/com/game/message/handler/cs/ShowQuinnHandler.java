package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.ShowQuinnRq;
import com.game.server.GameServer;
import com.game.service.QuinnService;

/**
 * @Description: 获取超时空财团活动界面
 */
public class ShowQuinnHandler extends ClientHandler {
	@Override
	public void action() {
	    ShowQuinnRq req = msg.getExtension(ShowQuinnRq.ext);
		GameServer.ac.getBean(QuinnService.class).showQuinn(req.getShowType(), req.getIsRefresh(), this);
	}

}
