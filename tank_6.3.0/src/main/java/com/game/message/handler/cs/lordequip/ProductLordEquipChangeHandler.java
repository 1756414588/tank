package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.LordEquipChangeRq;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @ClassName:ProductLordEquipChangeHandler
 * @author zc
 * @Description:处理军备淬炼
 * @date 2017年6月15日
 */
public class ProductLordEquipChangeHandler extends ClientHandler {

	@Override
	public void action() {
		LordEquipChangeRq req = msg.getExtension(LordEquipChangeRq.ext);
		GameServer.ac.getBean(LordEquipService.class).productLordEquipChange(req, this);
	}

}
