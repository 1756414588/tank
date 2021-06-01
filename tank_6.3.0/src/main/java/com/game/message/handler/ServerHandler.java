/**   
 * @Title: ServerHandler.java    
 * @Package com.game.message.handler    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月10日 下午12:18:01    
 * @version V1.0   
 */
package com.game.message.handler;

/**
 * @ClassName: ServerHandler
 * @Description: 账号服通信的基类
 * @author ZhangJun
 * @date 2015年8月10日 下午12:18:01
 * 
 */
abstract public class ServerHandler extends Handler {
    /**
     * 
    * <p>Title: dealType</p> 
    * <p>Description: </p> 
    * @return 得到交互类型
    * @see com.game.message.handler.Handler#dealType()
     */
	public DealType dealType() {
		//Auto-generated method stub
		return DealType.PUBLIC;
	}
}
