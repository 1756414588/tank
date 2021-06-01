/**   
* @Title: BuildPropHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月14日 下午5:53:36    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.BuildPropRq;
import com.game.service.PropService;

/**   
 * @ClassName: BuildPropHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月14日 下午5:53:36    
 *         
 */
public class BuildPropHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		BuildPropRq req = msg.getExtension(BuildPropRq.ext);
		getService(PropService.class).buildProp(req, this);
	}

}
