package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCReceiveCPRewardRq;
import com.game.pb.GamePb6;

public class ReceiveCPRewardHandler extends ClientHandler {

	@Override
	public void action() {
		CCReceiveCPRewardRq.Builder builder = CCReceiveCPRewardRq.newBuilder();
		builder.setRoleId(getRoleId());
		builder.setType(msg.getExtension(GamePb6.ReceiveCPRewardRq.ext).getType());

		sendMsgToCrossServer(CCReceiveCPRewardRq.EXT_FIELD_NUMBER, CCReceiveCPRewardRq.ext, builder.build());
	}

}
