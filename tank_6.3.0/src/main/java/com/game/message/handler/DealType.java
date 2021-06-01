/**   
 * @Title: DealType.java    
 * @Package com.game.message.handler    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月12日 下午1:48:51    
 * @version V1.0   
 */
package com.game.message.handler;

/**
 * @ClassName: DealType
 * @Description: handler队列类型的枚举
 * @author ZhangJun
 * @date 2015年8月12日 下午1:48:51
 * 
 */
public enum DealType {
    /**   目前用于账号付通信 */
	PUBLIC(0, "PUBLIC") {
	},
	 /**游戏服主要逻辑 */
	MAIN(1, "MAIN") {
	},
	 /**建筑  没用到*/
	BUILD_QUE(2, "BUILD_QUE") {
	},
	/**坦克   没用到 */
	TANK_QUE(3, "TANK_QUE") {
	},
	/** 与后台交互 */
	INNER(4, "INNER") {
	};
	
	public int getCode() {
		return code;
	}

	public void setCode(int code) {
		this.code = code;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	private DealType(int code, String name) {
		this.code = code;
		this.name = name;
	}

	private int code;
	private String name;
}
