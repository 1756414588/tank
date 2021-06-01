/**   
 * @Title: ArenaTime.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月9日 下午3:13:31    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: ArenaTime
 * @Description: 记录竞技场排名时间
 * @author ZhangJun
 * @date 2015年9月9日 下午3:13:31
 * 
 */
public class ArenaLog {
	private int keyId;
	private int arenaTime;
	private int count;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getArenaTime() {
		return arenaTime;
	}

	public void setArenaTime(int arenaTime) {
		this.arenaTime = arenaTime;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	/**      
	* @param keyId
	* @param arenaTime
	* @param count    
	*/
	public ArenaLog(int arenaTime, int count) {
		super();
		this.arenaTime = arenaTime;
		this.count = count;
	}

	/**      
	*     
	*/
	public ArenaLog() {
		super();
	}
	
	
}
