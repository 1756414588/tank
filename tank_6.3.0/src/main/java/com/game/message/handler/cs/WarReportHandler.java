/**   
* @Title: WarReportHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年12月21日 下午5:53:01    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.WarReportRq;
import com.game.service.WarService;

/**   
 * @ClassName: WarReportHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年12月21日 下午5:53:01    
 *         
 */
public class WarReportHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WarService.class).warReport(msg.getExtension(WarReportRq.ext), this);
	}

}
