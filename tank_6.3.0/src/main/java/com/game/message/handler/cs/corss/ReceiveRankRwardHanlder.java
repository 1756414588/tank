package com.game.message.handler.cs.corss;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCReceiveRankRwardRq;
import com.game.pb.GamePb4.ReceiveRankRwardRq;

public class ReceiveRankRwardHanlder extends ClientHandler {

	@Override
	public void action() {
		ReceiveRankRwardRq req = msg.getExtension(ReceiveRankRwardRq.ext);
		CCReceiveRankRwardRq.Builder builder = CCReceiveRankRwardRq.newBuilder();
		builder.setRoleId(getRoleId());
		builder.setGroup(req.getGroup());
		sendMsgToCrossServer(CCReceiveRankRwardRq.EXT_FIELD_NUMBER, CCReceiveRankRwardRq.ext, builder.build());
	}

}
