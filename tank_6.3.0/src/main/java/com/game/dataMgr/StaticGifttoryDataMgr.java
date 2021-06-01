package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticGifttory;
import com.game.domain.s.StaticGuideAwards;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author GuiJie
 * @description 点击宝箱获得奖励
 * @created 2018/01/30 14:00
 */
@Component
public class StaticGifttoryDataMgr extends BaseDataMgr {

	@Autowired
	private StaticDataDao staticDataDao;

	// 大富翁掉落礼盒
	private StaticGifttory staticGiftConfig;

	// 叛军头目掉落礼盒
	private StaticGifttory staticRebelConfig;

	private Map<Integer, StaticGuideAwards> gideAwards = new HashMap<>();

	@Override
	public void init() {

		List<StaticGifttory> staticGifttories = staticDataDao.selectGift();
		if (staticGifttories != null && !staticGifttories.isEmpty()) {
			staticGiftConfig = staticGifttories.get(0);
			staticRebelConfig = staticGifttories.get(1);
		}

		List<StaticGuideAwards> staticGuideAwards = staticDataDao.selectStaticGuideAwards();

		if (staticGuideAwards != null && !staticGuideAwards.isEmpty()) {
			for (StaticGuideAwards c : staticGuideAwards) {
				gideAwards.put(c.getId(), c);
			}
		}

	}

	public StaticGifttory getStaticGiftConfigConfig() {
		return staticGiftConfig;
	}
	
	public StaticGifttory getStaticRebelConfig() {
		return staticRebelConfig;
	}

	public StaticGuideAwards getGideAwards(int id) {
		return gideAwards.get(id);
	}
}
