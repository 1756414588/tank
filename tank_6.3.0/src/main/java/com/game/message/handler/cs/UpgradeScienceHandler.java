/**   
* @Title: GetChipHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月20日 上午10:27:33    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UpgradeScienceRq;
import com.game.service.ScienceService;

/**   
 * @ClassName: GetChipHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月20日 上午10:27:33    
 *         
 */
public class UpgradeScienceHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		UpgradeScienceRq req = msg.getExtension(UpgradeScienceRq.ext);
		getService(ScienceService.class).upgradeScience(req, this);
	}

}
