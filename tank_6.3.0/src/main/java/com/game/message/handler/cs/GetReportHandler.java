/**   
 * @Title: GetReportHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月24日 下午12:04:40    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GetReportRq;
import com.game.service.ChatService;

/**
 * @ClassName: GetReportHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月24日 下午12:04:40
 * 
 */
public class GetReportHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ChatService.class).getReport(msg.getExtension(GetReportRq.ext), this);
	}

}
