package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPersonSituationRq;
import com.game.pb.GamePb4.GetCrossPersonSituationRq;
import com.game.service.CrossService;

public class GetCrossPersonSituationHandler extends ClientHandler {



	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());

		GetCrossPersonSituationRq req = msg.getExtension(GetCrossPersonSituationRq.ext);

		CCGetCrossPersonSituationRq.Builder builder = CCGetCrossPersonSituationRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());
		builder.setPage(req.getPage());

		sendMsgToCrossServer(CCGetCrossPersonSituationRq.EXT_FIELD_NUMBER, CCGetCrossPersonSituationRq.ext,
				builder.build());
	}
}
