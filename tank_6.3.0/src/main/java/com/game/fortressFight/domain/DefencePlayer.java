/**   
 * @Title: DefencePlayer.java    
 * @Package com.game.fortressFight.domain    
 * @author WanYi  
 * @date 2016年6月4日 下午2:18:12    
 * @version V1.0   
 */
package com.game.fortressFight.domain;

import com.game.domain.Player;

/**
 * @ClassName: DefencePlayer
 * @author WanYi
 * @date 2016年6月4日 下午2:18:12
 * @Description: 防守方玩家
 * 
 */
public class DefencePlayer extends Defence {
	private Player player;
	private long fight;

	public Player getPlayer() {
		return player;
	}

	public void setPlayer(Player player) {
		this.player = player;
	}

	public long getFight() {
		return fight;
	}

	public void setFight(long fight) {
		this.fight = fight;
	}
}
