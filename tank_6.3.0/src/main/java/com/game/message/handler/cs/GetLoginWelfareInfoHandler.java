package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;
import com.game.util.LogUtil;

import java.text.ParseException;

/**
* @author: LiFeng
* @date: 2018年8月20日 上午10:53:29
* @description:
*/
public class GetLoginWelfareInfoHandler extends ClientHandler {

	@Override
	public void action() {
		try {
			getService(ActionCenterService.class).getLoginWelfareInfo(this);
		} catch (ParseException e) {
			LogUtil.error(e);
		}
	}

}
