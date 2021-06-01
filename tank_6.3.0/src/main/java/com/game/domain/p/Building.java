/**   
 * @Title: Building.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月20日 下午6:15:58    
 * @version V1.0   
 */
package com.game.domain.p;

import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.annotation.SaveOptimize;

/**
 * @ClassName: Building
 * @Description: 玩家建筑信息
 * @author ZhangJun
 * @date 2015年7月20日 下午6:15:58
 * 
 */
@SaveOptimize(level = SaveLevel.IDLE)
public class Building implements Cloneable {
	private long lordId;
	private int ware1;//第一仓库等级
	private int ware2;//第二仓库等级
	private int tech;//科技馆等级
	private int factory1;//第一战车工厂等级
	private int factory2;//第二战车工厂等级
	private int refit;//改装工厂等级
	private int command;//司令部等级
	private int workShop;//制造车间等级
    private int leqm;//军备材料工厂


	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getWare1() {
		return ware1;
	}

	public void setWare1(int ware1) {
		this.ware1 = ware1;
	}

	public int getWare2() {
		return ware2;
	}

	public void setWare2(int ware2) {
		this.ware2 = ware2;
	}

	public int getTech() {
		return tech;
	}

	public void setTech(int tech) {
		this.tech = tech;
	}

	public int getFactory1() {
		return factory1;
	}

	public void setFactory1(int factory1) {
		this.factory1 = factory1;
	}

	public int getFactory2() {
		return factory2;
	}

	public void setFactory2(int factory2) {
		this.factory2 = factory2;
	}

	public int getRefit() {
		return refit;
	}

	public void setRefit(int refit) {
		this.refit = refit;
	}

	public int getCommand() {
		return command;
	}

	public void setCommand(int command) {
		this.command = command;
	}

	public int getWorkShop() {
		return workShop;
	}

	public void setWorkShop(int workShop) {
		this.workShop = workShop;
	}

    public int getLeqm() {
        return leqm;
    }

    public void setLeqm(int leqm) {
        this.leqm = leqm;
    }

    @Override
	public Object clone() {
		try {
			return super.clone();
		} catch (CloneNotSupportedException e) {
			//Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
}
