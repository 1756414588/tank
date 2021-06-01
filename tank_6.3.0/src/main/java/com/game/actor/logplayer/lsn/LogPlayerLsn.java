package com.game.actor.logplayer.lsn;

import com.game.domain.p.MilitaryMaterial;
import com.game.domain.p.saveplayerinfo.*;
import com.game.server.Actor.IMessage;
import com.game.server.Actor.IMessageListener;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

/**
 * @ClassName:LogPlayerLsn
 * @author zc
 * @Description: 记录玩家详细信息
 * @date 2017年9月25日
 */

@Service
public class LogPlayerLsn implements IMessageListener {

	@Override
	public void onMessage(IMessage msg) {
		List<LogPlayer> list = (List<LogPlayer>) msg.getData();

		for (LogPlayer log : list) {
			long lordId = log.getLordId();
			String s = log.getServerId() + "|" + lordId + "|\"" + log.getNick() + "\"|" + log.getGold() + "|" + log.getVip()
					+ "|" + log.getFight() + "|" + (log.getLastLoginDay() == 0 ? "" : DateHelper.dateFormat1.format(new Date(log.getLastLoginDay()))) + "|";
			for (SaveMedal save : log.getMedalList()) {
				LogUtil.statistics("medal|" + s + save.getMedalId() + "|" + save.getMedalUpLv() + "|"
						+ save.getMedalRefitLv());
			}
			for (SaveLordEquip save : log.getLordEquipList()) {
				LogUtil.statistics("lordEquip|" + s + save.getEquipId() + "|" + save.getEquipLv() + "|" + save.getSkill());
			}
			for (SaveEquip save : log.getEquipList()) {
                LogUtil.statistics("equip|" + s + save.getEquipId() + "|" + save.getEquipLv());
            }
			for (SaveParts save : log.getPartsList()) {
                LogUtil.statistics("parts|" + s + save.getPartId() + "|" + save.getUpLv() + "|" + save.getRefitLv() + "|"
                        + save.getSmeltLv() + "|" + save.getPos());
            }
			for (SaveEnergyStone save : log.getEnergyStoneList()) {
                LogUtil.statistics("energyStone|" + s + save.getPropId() + "|" + save.getCount());
            }
			for (SaveMilitaryScience save : log.getMilitaryScienceList()) {
			    LogUtil.statistics("militaryScience|" + s + save.getTankId() + "|" + save.getCount());
            }
			for (MilitaryMaterial save : log.getMilitaryMaterialList()) {
			    LogUtil.statistics("militaryMaterial|" + s + save.getId() + "|" + save.getCount());
			}
		}
	}

}
