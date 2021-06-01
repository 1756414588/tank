/**   
* @Title: AttackFortressHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年6月7日 下午3:32:19    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.AttackFortressRq;
import com.game.service.FortressWarService;

/**   
 * @ClassName: AttackFortressHandler    
 * @Description: 攻击要塞战
 * @author WanYi   
 * @date 2016年6月7日 下午3:32:19    
 *         
 */
public class AttackFortressHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(FortressWarService.class).attackFortress(msg.getExtension(AttackFortressRq.ext),this);
	}

}
