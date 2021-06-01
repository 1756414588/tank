/**   
* @Title: InnerHandler.java    
* @Package com.game.message.handler    
* @Description:   
* @author ZhangJun   
* @date 2015年8月12日 下午2:34:44    
* @version V1.0   
*/
package com.game.message.handler;

import com.game.constant.GameError;
import com.game.domain.Player;
import com.game.pb.BasePb.Base;
import com.game.server.GameServer;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.google.protobuf.GeneratedMessage.GeneratedExtension;

/**
 * @ClassName: InnerHandler
 * @Description:  游戏内部服务器(跨服服务器)处理
 * @author ZhangJun
 * @date 2015年8月12日 下午2:34:44
 * 
 */
abstract public class InnerHandler extends Handler {

	/**
	 * 
	* <p>Title: dealType</p> 
	* <p>Description:交互类型 </p> 
	* @return 
	* @see com.game.message.handler.Handler#dealType()
	 */
	@Override
	public DealType dealType() {
		//Auto-generated method stub
		return DealType.MAIN;
	}
	
	/**
	 * 
	* @Title: sendMsgToPlayer 
	* @Description: 向玩家发送协议消息
	* @param player 玩家对象
	* @param baseBuilder  协议消息
	* void   

	 */
	public void sendMsgToPlayer(Player player, Base.Builder baseBuilder) {

		if(player != null ){
			if(player.ctx != null){
				GameServer.getInstance().sendMsgToPlayer(player.ctx, baseBuilder);
			}else {
				LogUtil.error("sendMsgToPlayer ctx is null roleId="+player.lord.getLordId());
			}
		}
	}

	/**
	 * 
	* @Title: sendErrorMsgToPlayer 
	* @Description: 向玩家发送错误码
	* @param player 玩家对象
	* @param gameError  协议消息
	* void   

	 */
	public void sendErrorMsgToPlayer(Player player, GameError gameError) {
		Base.Builder baseBuilder = createRsBase(gameError.getCode());
		sendMsgToPlayer(player, baseBuilder);
	}

	/**
	 * 
	* @Title: sendMsgToPlayer 
	* @Description: 向玩家发送协议消息
	* @param player 玩家对象
	* @param ext 协议生成器
	* @param cmdCode  协议的编号
	* @param msg   消息内容
	* void   

	 */
	public <T> void sendMsgToPlayer(Player player, GeneratedExtension<Base, T> ext, int cmdCode, T msg) {
		Base.Builder baseBuilder = createRsBase(GameError.OK, ext, cmdCode, msg);
		sendMsgToPlayer(player, baseBuilder);
	}

	/**
	 * 
	* @Title: sendMsgToPlayer 
	* @Description: 向玩家发送协议消息
	* @param player  玩家对象
	* @param code  错误码
	* @param ext 协议生成器
    * @param cmdCode  协议的编号
    * @param msg   消息内容
	* void   

	 */
	public <T> void sendMsgToPlayer(Player player, int code, GeneratedExtension<Base, T> ext, int cmdCode, T msg) {
		Base.Builder baseBuilder = createRsBase(code, ext, cmdCode, msg);
		sendMsgToPlayer(player, baseBuilder);
	}

	/**
	 * 
	* @Title: createRsBase 
	* @Description: 构造协议
	* @param gameError 错误码枚举对象
    * @param ext 协议生成器
    * @param cmdCode  协议的编号
    * @param msg   消息内容
	* @return  
	* Base.Builder   

	 */
	public <T> Base.Builder createRsBase(GameError gameError, GeneratedExtension<Base, T> ext, int cmdCode, T msg) {
		Base.Builder baseBuilder = Base.newBuilder();
		baseBuilder.setCmd(cmdCode);
		baseBuilder.setCode(gameError.getCode());
		if (this.msg.hasParam()) {
			baseBuilder.setParam(this.msg.getParam());
		}
		if (msg != null) {
			baseBuilder.setExtension(ext, msg);
		}
		return baseBuilder;
	}

	/**
	 * 
	* @Title: createRsBase 
	* @Description: 构造协议
	* @param code 错误码
    * @param ext 协议生成器
    * @param cmdCode  协议的编号
    * @param msg   消息内容
	* @return  
	* Base.Builder   

	 */
	public <T> Base.Builder createRsBase(int code, GeneratedExtension<Base, T> ext, int cmdCode, T msg) {
		Base.Builder baseBuilder = Base.newBuilder();
		baseBuilder.setCmd(cmdCode);
		baseBuilder.setCode(code);
		if (this.msg.hasParam()) {
			baseBuilder.setParam(this.msg.getParam());
		}
		if (code == GameError.OK.getCode()) {
			if (msg != null) {
				baseBuilder.setExtension(ext, msg);
			}
		}

		return baseBuilder;
	}

	/**
	 * 
	* @Title: sendMsgToCrossServer 
	* @Description: 发消息到账号服
	* @param command
	* @param ext 协议生成器
	* @param msg  协议的编号
	* void   

	 */
	public <T> void sendMsgToCrossServer(int command, GeneratedExtension<Base, T> ext, T msg) {
		Base.Builder baseBuilder = PbHelper.createRqBase(command, null, ext, msg);
		sendMsgToCrossServer(baseBuilder);
	}

	/**
	 * 
	* @Title: sendMsgToCrossServer 
	* @Description:  发送消息发到账号服
	* @param baseBuilder  协议消息
	* void   

	 */
	private void sendMsgToCrossServer(Base.Builder baseBuilder) {
		GameServer.getInstance().sendMsgToCross(baseBuilder);
	}
}
