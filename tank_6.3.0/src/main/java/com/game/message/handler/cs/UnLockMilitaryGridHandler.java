/**   
* @Title: UnLockMilitaryGridHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年5月13日 下午4:57:05    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.UnLockMilitaryGridRq;
import com.game.service.MilitaryScienceService;

/**   
 * @ClassName: UnLockMilitaryGridHandler    
 * @Description:     
 * @author WanYi   
 * @date 2016年5月13日 下午4:57:05    
 *         
 */
public class UnLockMilitaryGridHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		getService(MilitaryScienceService.class).unLockMilitaryGrid(msg.getExtension(UnLockMilitaryGridRq.ext),this);
	}

}
