package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.ActCumulativeRePayRq;
import com.game.service.ActionCenterService;

/**
 * @ClassName:ActCumulativeRePayHandler
 * @author zc
 * @Description:
 * @date 2017年7月10日
 */
public class ActCumulativeRePayHandler extends ClientHandler {

	@Override
	public void action() {
		ActCumulativeRePayRq req = msg.getExtension(ActCumulativeRePayRq.ext);
		getService(ActionCenterService.class).ActCumulativeRePay(req, this);
	}

}
