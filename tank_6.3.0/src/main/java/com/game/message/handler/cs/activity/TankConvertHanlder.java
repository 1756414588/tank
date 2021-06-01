package com.game.message.handler.cs.activity;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.TankConvertRq;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class TankConvertHanlder extends ClientHandler{

	@Override
	public void action() {
		TankConvertRq rq = msg.getExtension(TankConvertRq.ext);
		getService(ActionCenterService.class).tankConvert(this, rq.getCount(), rq.getSrcTankId(), rq.getDstTankId());
	}

}
