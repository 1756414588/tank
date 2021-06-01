/**   
 * @Title: ExtremeRecordHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月28日 下午2:36:55    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.ExtremeRecordRq;
import com.game.service.CombatService;

/**
 * @ClassName: ExtremeRecordHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月28日 下午2:36:55
 * 
 */
public class ExtremeRecordHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(CombatService.class).extremeRecord(msg.getExtension(ExtremeRecordRq.ext), this);
	}

}
