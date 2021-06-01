package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticGifttoryDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Prop;
import com.game.domain.s.StaticGifttory;
import com.game.domain.s.StaticGuideAwards;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.util.DateHelper;
import com.game.util.LotteryUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/02/09 11:57
 */
@Service
public class BoxRewardService {
	@Autowired
	private PlayerDataManager playerDataManager;
	@Autowired
	private StaticGifttoryDataMgr staticGifttoryDataMgr;
	@Autowired
	private RewardService rewardService;

	/**
	 * 点击宝箱获得奖励
	 *
	 * @param handler
	 */
	public void getGiftReward(GamePb6.GetGiftRewardRq rq, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		// 如果不是同一天就重置次数
		if (player.giftRewardTime != 0 && !DateHelper.isSameDate(new Date(), new Date(player.giftRewardTime * 1000L))) {
			player.giftRewardCount = 0;
		}

		StaticGifttory config = staticGifttoryDataMgr.getStaticGiftConfigConfig();

		GamePb6.GetGiftRewardRs.Builder builder = GamePb6.GetGiftRewardRs.newBuilder();
		if (player.giftRewardCount < config.getMaxCount()) {

			player.giftRewardTime = (int) (System.currentTimeMillis() / 1000);
			player.giftRewardCount = player.giftRewardCount + 1;

			List<List<Integer>> reward = config.getReward();
			Map<List<Integer>, Float> rewardMap = new HashMap<>();
			for (List<Integer> it : reward) {
				float roll = (float) (it.get(3) * 1.0);
				rewardMap.put(it, roll);
			}

			List<Integer> item = LotteryUtil.getRandomKey(rewardMap);
			rewardService.addAward(player, item.get(0), item.get(1), item.get(2), AwardFrom.GIFT_REWARD);
			CommonPb.Award awardPb = PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2));
			builder.addAward(awardPb);
		}

		handler.sendMsgToPlayer(GamePb6.GetGiftRewardRs.ext, builder.build());
	}

	/**
	 * 新手引导获取奖励
	 *
	 * @param rq
	 * @param handler
	 */
	public void getGuideReward(GamePb6.GetGuideRewardRq rq, ClientHandler handler) {
		int index = rq.getIndex();
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		if (player.getGuideRewardInfo().contains(index)) {
			handler.sendErrorMsgToPlayer(GameError.RED_PLAN_REWARD);
			return;
		}

		StaticGuideAwards config = staticGifttoryDataMgr.getGideAwards(index);
		if (config == null) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}

		player.getGuideRewardInfo().add(index);

		Prop prop = player.props.get(58);

		int count = 4 - index;

		// 如果没有就加3个
		if (prop == null) {
			playerDataManager.addProp(player, 58, count, AwardFrom.GET_GUIDE_REWARD);
		}

		// 如果少于三个就加到三个
		if (prop != null && prop.getCount() < count) {
			if (count > 0) {
				playerDataManager.addProp(player, 58, count, AwardFrom.GET_GUIDE_REWARD);
			}
		}

		GamePb6.GetGuideRewardRs.Builder builder = GamePb6.GetGuideRewardRs.newBuilder();

		prop = player.props.get(58);

		if (prop != null) {
			playerDataManager.subProp(player, prop, 1, AwardFrom.GET_GUIDE_REWARD);
			builder.setCount(prop.getCount());
		} else {
			builder.setCount(0);
		}

		List<List<Integer>> awards = config.getAwards();
		for (List<Integer> item : awards) {
			rewardService.addAward(player, item.get(0), item.get(1), item.get(2), AwardFrom.GET_GUIDE_REWARD);
			CommonPb.Award awardPb = PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2));
			builder.addAward(awardPb);
		}
		handler.sendMsgToPlayer(GamePb6.GetGuideRewardRs.ext, builder.build());
	}

}
