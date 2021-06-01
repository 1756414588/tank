package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetFortressJiFenRankRq;
import com.game.service.FortressWarService;

/**
 * 获取要塞积分排名
 * @author wanyi
 *
 */
public class GetFortressJiFenRankHandler extends ClientHandler {

	@Override
	public void action() {
		getService(FortressWarService.class).getFortressJiFenRank(msg.getExtension(GetFortressJiFenRankRq.ext),this);
	}

}
