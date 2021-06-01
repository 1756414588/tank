package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.RewardAllMailRq;
import com.game.service.MailService;

/**
 * @ClassName:RewardAllMailHandler
 * @author zc
 * @Description:一键获取所有邮件附件
 * @date 2017年7月18日
 */
public class RewardAllMailHandler extends ClientHandler {
	@Override
	public void action() {
		RewardAllMailRq req = msg.getExtension(RewardAllMailRq.ext);
		getService(MailService.class).rewardAllMailRq(req, this);
	}
}
