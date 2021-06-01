/**   
* @Title: GetMilitaryScienceGridHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年5月10日 下午2:34:31    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.MilitaryScienceService;

/** 获取军工科技格子状态信息
 * @ClassName: GetMilitaryScienceGridHandler    
 * @Description:     
 * @author WanYi   
 * @date 2016年5月10日 下午2:34:31    
 *         
 */
public class GetMilitaryScienceGridHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(MilitaryScienceService.class).getMilitaryScienceGrid(this);
	}

}
