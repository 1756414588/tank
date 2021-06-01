package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetFortressCombatStaticsRq;
import com.game.service.FortressWarService;

/**
 * 获取要塞战绩统计
 * @author I
 *
 */
public class GetFortressCombatStaticsHandler extends ClientHandler {

	@Override
	public void action() {
		getService(FortressWarService.class).getFortressCombatStatics(msg.getExtension(GetFortressCombatStaticsRq.ext),this);
	}

}
