/**
 * @Title: Handler.java @Package com.game.server.handler @Description: TODO
 * @author ZhangJun
 * @date 2015年7月30日 下午3:00:04
 * @version V1.0
 */
package com.game.message.handler;

import com.game.constant.GameError;
import com.game.pb.BasePb.Base;
import com.game.server.GameContext;
import com.game.server.ICommand;
import com.game.server.util.ChannelUtil;
import com.google.protobuf.GeneratedMessage.GeneratedExtension;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author ZhangJun
 * @ClassName: Handler @Description: TODO
 * @date 2015年7月30日 下午3:00:04
 */
public abstract class Handler implements ICommand {
    public static final int PUBLIC = 0;
    public static final int MAIN = 1;
    public static final int BUILD_QUE = 2;
    public static final int TANK_QUE = 3;

    private int rsMsgCmd;
    protected ChannelHandlerContext ctx;
    protected Base msg;
    protected long createTime;

    public Handler(ChannelHandlerContext ctx, Base msg) {
        this.ctx = ctx;
        this.msg = msg;
        setCreateTime(System.currentTimeMillis());
    }

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
        return GameContext.getAc().getBean(c);
    }

    public Long getChannelId() {
        return ChannelUtil.getChannelId(ctx);
    }

    public void sendMsgToPublic(Base.Builder baseBuilder) {
        GameContext.sendMsgToPublic(baseBuilder);
    }

    public abstract DealType dealType();

    public int getRsMsgCmd() {
        return rsMsgCmd;
    }

    public void setRsMsgCmd(int rsMsgCmd) {
        this.rsMsgCmd = rsMsgCmd;
    }


}
