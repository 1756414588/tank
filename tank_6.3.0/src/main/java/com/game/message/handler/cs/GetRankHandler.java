/**   
 * @Title: GetRankHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年10月8日 下午5:35:11    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.manager.RankDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GetRankRq;
import com.game.service.ArenaService;

/**
 * @ClassName: GetRankHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年10月8日 下午5:35:11
 * 
 */
public class GetRankHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		GetRankRq req = msg.getExtension(GetRankRq.ext);
		int type = req.getType();
		int page = req.getPage();
		if (type == 7) {
			getService(ArenaService.class).getRankData(page, this);
		} else {
			getService(RankDataManager.class).getRank(type, page, this);
		}
	}

}
