/**   
* @Title: SetFortressBattleFormHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年6月7日 上午11:25:23    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.SetFortressBattleFormRq;
import com.game.service.FortressWarService;

/**   
 * @ClassName: SetFortressBattleFormHandler    
 * @Description: 设置军团防守
 * @author WanYi   
 * @date 2016年6月7日 上午11:25:23    
 *         
 */
public class SetFortressBattleFormHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(FortressWarService.class).setFortressBattleForm(msg.getExtension(SetFortressBattleFormRq.ext), this);
	}

}
