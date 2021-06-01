/**   
\* @Title: GetMapHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月12日 下午4:05:53    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GetMapRq;
import com.game.service.WorldService;

/**   
 * @ClassName: GetMapHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月12日 下午4:05:53    
 *         
 */
public class GetMapHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		GetMapRq req = msg.getExtension(GetMapRq.ext);
		getService(WorldService.class).getMap(req.getArea(), this);
	}

}
