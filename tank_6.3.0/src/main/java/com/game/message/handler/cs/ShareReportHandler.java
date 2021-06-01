/**   
 * @Title: ShareReportHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月24日 下午12:05:39    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.ShareReportRq;
import com.game.service.ChatService;

/**
 * @ClassName: ShareReportHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月24日 下午12:05:39
 * 
 */
public class ShareReportHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ChatService.class).shareChat(msg.getExtension(ShareReportRq.ext), this);
	}

}
