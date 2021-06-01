package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.DoActEquipDialRq;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class DoActEquipDialHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).doActEquip(msg.getExtension(DoActEquipDialRq.ext), this);
	}

}
