package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.HeroAwakenSkillLvRq;
import com.game.service.HeroService;

public class HeroAwakenLvSkillHandler extends ClientHandler {

	@Override
	public void action() {
		HeroAwakenSkillLvRq req = msg.getExtension(HeroAwakenSkillLvRq.ext);
		getService(HeroService.class).heroAwakenSkillLv(req.getKeyId(),req.getId(),this);
	}

}
