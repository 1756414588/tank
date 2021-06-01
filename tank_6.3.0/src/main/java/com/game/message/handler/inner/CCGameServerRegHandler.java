package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGameServerRegRs;
import com.game.util.LogHelper;
import com.game.util.LogUtil;

public class CCGameServerRegHandler extends InnerHandler {

	@Override
	public void action() {
		CCGameServerRegRs rs = msg.getExtension(CCGameServerRegRs.ext);
		LogUtil.crossInfo("注册CROSS服成功");
	}

}
