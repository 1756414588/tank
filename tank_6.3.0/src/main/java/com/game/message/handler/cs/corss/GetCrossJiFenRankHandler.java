package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossJiFenRankRq;
import com.game.pb.GamePb4.GetCrossJiFenRankRq;
import com.game.service.CrossService;

public class GetCrossJiFenRankHandler extends ClientHandler {


	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());

		GetCrossJiFenRankRq req = msg.getExtension(GetCrossJiFenRankRq.ext);

		CCGetCrossJiFenRankRq.Builder builder = CCGetCrossJiFenRankRq.newBuilder();

		builder.setPage(req.getPage());

		builder.setRoleId(player.lord.getLordId());

		sendMsgToCrossServer(CCGetCrossJiFenRankRq.EXT_FIELD_NUMBER, CCGetCrossJiFenRankRq.ext, builder.build());
	}

}
