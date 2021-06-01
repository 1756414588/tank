/**   
 * @Title: GetExtremeHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月28日 下午2:35:34    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GetExtremeRq;
import com.game.service.CombatService;

/**
 * @ClassName: GetExtremeHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月28日 下午2:35:34
 * 
 */
public class GetExtremeHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(CombatService.class).getExtreme(msg.getExtension(GetExtremeRq.ext).getExtremeId(), this);
	}

}
