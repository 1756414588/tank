package com.game.message.handler.cs.corss;

import com.game.constant.GameError;
import com.game.domain.Player;
import com.game.domain.p.Arena;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCCrossFightRegRq;
import com.game.pb.GamePb4.CrossFightRegRq;
import com.game.service.CrossService;

public class CrossFightRegHandler extends ClientHandler {

	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());

		CCCrossFightRegRq.Builder builder = CCCrossFightRegRq.newBuilder();

		builder.setRoleId(player.lord.getLordId());
		builder.setGroupId(msg.getExtension(CrossFightRegRq.ext).getGroupId());

		Arena arena = getService(CrossService.class).getArena(getRoleId());
		if (arena == null) {
			sendErrorMsgToPlayer(GameError.CROSS_NO_RANK_REG);
			return;
		}
		builder.setRankId(arena.getLastRank());
		builder.setFight(player.lord.getFight());
		builder.setNick(player.lord.getNick());
		builder.setPortrait(player.lord.getPortrait());
		builder.setLevel(player.lord.getLevel());

		String partyName = getService(CrossService.class).getParyName(getRoleId());
		if (partyName != null) {
			builder.setPartyName(partyName);
		}

		sendMsgToCrossServer(CCCrossFightRegRq.EXT_FIELD_NUMBER, CCCrossFightRegRq.ext, builder.build());
	}

}
