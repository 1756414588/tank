package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.airship.AirshipService;

/**
 * @ClassName:GetRecvAirshipProduceAwardRecordHandler
 * @author zc
 * @Description: 获取飞艇征收记录
 * @date 2017年8月12日
 */
public class GetRecvAirshipProduceAwardRecordHandler extends ClientHandler {
	@Override
	public void action() {
		 GamePb5.GetRecvAirshipProduceAwardRecordRq req = msg.getExtension(GamePb5.GetRecvAirshipProduceAwardRecordRq.ext);
	     GameServer.ac.getBean(AirshipService.class).getRecvAirshipProduceAwardRecord(req.getAirshipId(), this);
	}

}
