package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.BuyInBuckRq;
import com.game.service.ActionCenterService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class BuyInBuckHandler extends ClientHandler {

	@Override
	public void action() {
		BuyInBuckRq rq = msg.getExtension(BuyInBuckRq.ext);
		int activityId = rq.getActivityId();
		int count = rq.getCount();
		int goodId = rq.getGoodId();
		getService(ActionCenterService.class).buyInBuck(this, activityId, goodId, count);
	}

}
