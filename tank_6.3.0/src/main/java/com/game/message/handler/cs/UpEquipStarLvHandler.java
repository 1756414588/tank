/**   
* @Title: UpEquipHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月18日 下午3:53:45    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.EquipService;

public class UpEquipStarLvHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		GamePb6.UpEquipStarLvRq req = msg.getExtension(GamePb6.UpEquipStarLvRq.ext);
		getService(EquipService.class).upEquipStarLv(req, this);
	}
}
