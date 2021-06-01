/**   
 * @Title: GetNamesHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月6日 下午6:07:28    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.constant.GameError;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.GamePb1.GetNamesRs;
import com.game.service.PlayerService;

/**
 * @ClassName: GetNamesHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月6日 下午6:07:28
 * 
 */
public class GetNamesHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		PlayerService playerService = getService(PlayerService.class);
		
		GetNamesRs.Builder builder = GetNamesRs.newBuilder();
		builder.addAllName(playerService.getAvailabelNames());
		Base.Builder baseBuilder = Base.newBuilder();
		baseBuilder.setCmd(GetNamesRs.EXT_FIELD_NUMBER);
		baseBuilder.setCode(GameError.OK.getCode());
		baseBuilder.setExtension(GetNamesRs.ext, builder.build());
		sendMsgToPlayer(baseBuilder);
	}

}
