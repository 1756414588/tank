package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.LordEquipChangeFreeTimeRq;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @ClassName:GetLordEquipChangFreeTimeeHandler
 * @Description:获取免费洗练次数和恢复时间
 * @author zc
 * @date 2017年6月15日
 */
public class GetLordEquipChangFreeTimeeHandler extends ClientHandler {

	@Override
	public void action() {
		LordEquipChangeFreeTimeRq req = msg.getExtension(LordEquipChangeFreeTimeRq.ext);
        GameServer.ac.getBean(LordEquipService.class).getLordEquipChangFreeTime(req, this);
	}

}
