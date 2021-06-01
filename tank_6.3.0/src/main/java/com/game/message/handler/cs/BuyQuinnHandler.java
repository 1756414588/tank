package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.QuinnService;

/**

 * @Description: 购买超时空军团商品
 */
public class BuyQuinnHandler extends ClientHandler {
	@Override
	public void action() {
	    GamePb6.BuyQuinnRq req = msg.getExtension(GamePb6.BuyQuinnRq.ext);
		GameServer.ac.getBean(QuinnService.class).buyQuinn(req.getType(), this);
	}

}
