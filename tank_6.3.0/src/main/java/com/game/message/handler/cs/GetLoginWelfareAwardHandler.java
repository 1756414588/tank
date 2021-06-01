package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetLoginWelfareAwardRq;
import com.game.service.ActionCenterService;

/**
 * @author: LiFeng
 * @date: 2018年8月20日 上午10:54:50
 * @description:
 */
public class GetLoginWelfareAwardHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getLoginWelfareAward(this, msg.getExtension(GetLoginWelfareAwardRq.ext));
	}

}
