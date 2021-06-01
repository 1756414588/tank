/**   
 * @Title: ManShare.java    
 * @Package com.game.chat.domain    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 下午5:49:55    
 * @version V1.0   
 */
package com.game.chat.domain;

import com.game.constant.SkinType;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.fortressFight.domain.FortressJobAppoint;
import com.game.manager.WarDataManager;
import com.game.pb.CommonPb;
import com.game.server.GameServer;
import com.game.util.TimeHelper;

/**
 * @ClassName: ManShare
 * @Description: 玩家分享，军团招募的聊天消息对象
 * @author ZhangJun
 * @date 2015年9月21日 下午5:49:55
 * 
 */
public class ManShare extends Chat {
	private Player player;
	private int time;
	private int id;
	private String[] param;
	private int report;
	private int sysId;
	private CommonPb.TankData tankData;
	private int heroId;
	private CommonPb.MedalData medalData;
	private CommonPb.AwakenHero awakenHero;

	public Player getPlayer() {
		return player;
	}

	public void setPlayer(Player player) {
		this.player = player;
	}

	public int getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String[] getParam() {
		return param;
	}

	public void setParam(String[] param) {
		this.param = param;
	}

	public int getReport() {
		return report;
	}

	public void setReport(int report) {
		this.report = report;
	}

	/**
	 * Overriding: ser
	 * 
	 * @return
	 */
	@Override
	public CommonPb.Chat ser(int style) {
		//Auto-generated method stub
		CommonPb.Chat.Builder builder = CommonPb.Chat.newBuilder();
		Lord lord = player.lord;
		builder.setTime(time);
		builder.setChannel(channel);
		builder.setName(lord.getNick());
		builder.setPortrait(lord.getPortrait());
		builder.setBubble(player.getCurrentSkin(SkinType.BUBBLE));
		if (lord.getVip() > 0) {
			builder.setVip(lord.getVip());
		}

		if (id != 0) {
			builder.setId(id);
		}

		if (param != null) {
			for (int i = 0; i < param.length; i++) {
				if (param[i] != null) {
					builder.addParam(param[i]);
				}
			}
		}

		if (report != 0) {
			builder.setReport(report);
		}

		if (tankData != null) {
			builder.setTankData(tankData);
		}

		if (sysId != 0) {
			builder.setSysId(sysId);
		}
		
		if (heroId != 0) {
			builder.setHeroId(heroId);
		}
		
		if (medalData != null) {
			builder.setMedalData(medalData);
		}
		
		if (awakenHero != null) {
			builder.setAwakenHero(awakenHero);
		}
		
		if (player.account.getIsGuider() > 0) {
			builder.setIsGuider(true);
		}
		
		builder.setStaffing(player.lord.getStaffing());

        //军衔
        if (GameServer.ac.getBean(StaticFunctionPlanDataMgr.class).isMilitaryRankOpen()){
            builder.setMilitaryRank(player.lord.getMilitaryRank());
        }
		
		FortressJobAppoint f = GameServer.ac.getBean(WarDataManager.class).getFortressJobAppointMapByLordId()
				.get(lord.getLordId());
		if (f != null && f.getEndTime() >= TimeHelper.getCurrentSecond()) {
			builder.setFortressJobId(f.getJobId());
		}

		builder.setRoleId(lord.getLordId());

		return builder.build();
	}

	public CommonPb.TankData getTankData() {
		return tankData;
	}

	public void setTankData(CommonPb.TankData tankData) {
		this.tankData = tankData;
	}

	public int getSysId() {
		return sysId;
	}

	public void setSysId(int sysId) {
		this.sysId = sysId;
	}

	public int getHeroId() {
		return heroId;
	}

	public void setHeroId(int heroId) {
		this.heroId = heroId;
	}
	
	public void setMedalData(CommonPb.MedalData medalData) {
		this.medalData = medalData;
	}

	public void setAwakenHero(CommonPb.AwakenHero awakenHero) {
		this.awakenHero = awakenHero;
	}
}
