package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.SetPlayerAttackSeqRq;
import com.game.service.airship.AirshipTeamService;

public class SetPlayerAttackSeqHandler extends ClientHandler {
	
	@Override
	public void action() {
		SetPlayerAttackSeqRq req = msg.getExtension(SetPlayerAttackSeqRq.ext);
		if(req.getIsGuard()){
			getService(AirshipTeamService.class).setPlayerGuardSeq(req,this);
		}else{
			getService(AirshipTeamService.class).setPlayerAttackSeq(req,this);
		}
	}

}
