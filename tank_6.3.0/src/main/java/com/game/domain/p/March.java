/**   
 * @Title: March.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月16日 上午10:08:18    
 * @version V1.0   
 */
package com.game.domain.p;

import com.game.domain.Player;

/**
 * @ClassName: March
 * @Description: 进军数据
 * @author ZhangJun
 * @date 2015年9月16日 上午10:08:18
 * 
 */
public class March {
	private Player player;
	private Army army;

	public Player getPlayer() {
		return player;
	}

	public void setPlayer(Player player) {
		this.player = player;
	}

	public Army getArmy() {
		return army;
	}

	public void setArmy(Army army) {
		this.army = army;
	}

	/**
	 * @param player
	 * @param army
	 */
	public March(Player player, Army army) {
		super();
		this.player = player;
		this.army = army;
	}

}
