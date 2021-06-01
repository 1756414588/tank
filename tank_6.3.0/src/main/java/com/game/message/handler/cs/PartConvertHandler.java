package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.PartConvertRq;
import com.game.service.PartService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class PartConvertHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PartService.class).partConvert(this, msg.getExtension(PartConvertRq.ext));
	}

}
