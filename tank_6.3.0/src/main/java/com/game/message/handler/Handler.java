/**   
 * @Title: Handler.java    
 * @Package com.game.server.handler    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月30日 下午3:00:04    
 * @version V1.0   
 */
package com.game.message.handler;

import io.netty.channel.ChannelHandlerContext;

import com.game.constant.GameError;
import com.game.pb.BasePb.Base;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.server.util.ChannelUtil;
import com.google.protobuf.GeneratedMessage.GeneratedExtension;

/**
 * @ClassName: Handler
 * @Description:  消息处理器基类
 * @author ZhangJun
 * @date 2015年7月30日 下午3:00:04
 * 
 */
abstract public class Handler implements ICommand {
	static public final int PUBLIC = 0;
	static public final int MAIN = 1;
	static public final int BUILD_QUE = 2;
	static public final int TANK_QUE = 3;

	private int rsMsgCmd;
	protected ChannelHandlerContext ctx;
	protected Base msg;
	protected long createTime;

	/**
	 * 
	* Title: 
	* Description: 
	* @param ctx 连接上下文
	* @param msg 协议消息
	 */
	public Handler(ChannelHandlerContext ctx, Base msg) {
		this.ctx = ctx;
		this.msg = msg;
		setCreateTime(System.currentTimeMillis());
	}

	/**
	 * 
	* Title: 
	* Description:
	 */
	public Handler() {
		setCreateTime(System.currentTimeMillis());
	}

	public ChannelHandlerContext getCtx() {
		return ctx;
	}

	public void setCtx(ChannelHandlerContext ctx) {
		this.ctx = ctx;
	}

	public Base getMsg() {
		return msg;
	}

	public void setMsg(Base msg) {
		this.msg = msg;
	}

	public long getCreateTime() {
		return createTime;
	}

	public void setCreateTime(long createTime) {
		this.createTime = createTime;
	}

	/**
	 * 
	* @Title: createRsBase 
	* @Description: 构建返回协议消息
	* @param gameError 错误枚举
	* @param ext 协议生成器
	* @param msg 消息内容
	* @return  
	* Base.Builder   
	 */
	public <T> Base.Builder createRsBase(GameError gameError, GeneratedExtension<Base, T> ext, T msg) {
		Base.Builder baseBuilder = Base.newBuilder();
		baseBuilder.setCmd(rsMsgCmd);
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
	* @Description: 构建返回协议消息
	* @param code  错误码
    * @param ext 协议生成器
    * @param msg 消息内容
	* @return  
	* Base.Builder   

	 */
	public <T> Base.Builder createRsBase(int code, GeneratedExtension<Base, T> ext, T msg) {
		Base.Builder baseBuilder = Base.newBuilder();
		baseBuilder.setCmd(rsMsgCmd);
		baseBuilder.setCode(code);
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
	* @Description:  构建返回协议消息  使用默认消息
	* @param code 错误码
	* @return  
	* Base.Builder   

	 */
	public Base.Builder createRsBase(int code) {
		Base.Builder baseBuilder = Base.newBuilder();
		baseBuilder.setCmd(rsMsgCmd);
		baseBuilder.setCode(code);
		if (this.msg.hasParam()) {
			baseBuilder.setParam(this.msg.getParam());
		}
		return baseBuilder;
	}

	public <T> T getService(Class<T> c) {
		return GameServer.ac.getBean(c);
	}

	public Long getChannelId() {
		return ChannelUtil.getChannelId(ctx);
	}

	public void sendMsgToPublic(Base.Builder baseBuilder) {
		GameServer.getInstance().sendMsgToPublic(baseBuilder);
	}
	
	abstract public DealType dealType();

	public int getRsMsgCmd() {
		return rsMsgCmd;
	}

	public void setRsMsgCmd(int rsMsgCmd) {
		this.rsMsgCmd = rsMsgCmd;
	}
	
}
