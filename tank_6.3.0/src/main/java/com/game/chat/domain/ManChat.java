/**   
 * @Title: ManChat.java    
 * @Package com.game.chat.domain    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 下午4:48:38    
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
 * @ClassName: ManChat
 * @Description: 普通聊天消息
 * @author ZhangJun
 * @date 2015年9月21日 下午4:48:38
 * 
 */
public class ManChat extends Chat {
	private Player player;
	private int time;
	private String msg;

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

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	/**
	 * Overriding: ser
	 * 
	 * @return
	 * @see com.game.chat.domain.Chat#ser()
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
		builder.setRoleId(lord.getLordId());
		if (lord.getVip() > 0) {
			builder.setVip(lord.getVip());
		}
		
		if (style != 0) {
			builder.setStyle(style);
		}
		builder.setMsg(msg);
		if (player.account.getIsGm() > 0) {
			builder.setIsGm(true);
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
		
		return builder.build();
	}

}
