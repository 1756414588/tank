package com.game.message.handler;

import com.game.constant.GameError;
import com.game.pb.BasePb.Base;
import com.game.server.GameContext;
import com.game.server.util.ChannelUtil;
import com.google.protobuf.GeneratedMessage.GeneratedExtension;

/**
 * @author ZhangJun
 * @ClassName: ClientHandler @Description: TODO
 * @date 2015年8月10日 下午12:16:21
 */
public abstract class ClientHandler extends Handler {
    public void sendMsgToPlayer(Base.Builder baseBuilder) {
        GameContext.sendMsgToPlayer(ctx, baseBuilder);
    }

    public Long getRoleId() {
        return ChannelUtil.getRoleId(ctx);
    }

    @Override
    public DealType dealType() {
        return DealType.MAIN;
    }

    public void sendErrorMsgToPlayer(GameError gameError) {
        Base.Builder baseBuilder = createRsBase(gameError.getCode());
        sendMsgToPlayer(baseBuilder);
    }

    public <T> void sendMsgToPlayer(GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = createRsBase(GameError.OK, ext, msg);
        sendMsgToPlayer(baseBuilder);
    }

    public <T> void sendMsgToPlayer(GameError gameError, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = createRsBase(gameError, ext, msg);
        sendMsgToPlayer(baseBuilder);
    }

    public int getServerId() {
        return ChannelUtil.getServerId(ctx);
    }


    public void sendErrorMsgToGameMin(GameError gameError) {
        Base.Builder baseBuilder = createRsBase(gameError.getCode());
        sendMsgToGameMin(baseBuilder);
    }

    public <T> void sendMsgToGameMin(GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = createRsBase(GameError.OK, ext, msg);
        sendMsgToGameMin(baseBuilder);
    }

    public <T> void sendMsgToGameMin(GameError gameError, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = createRsBase(gameError, ext, msg);
        sendMsgToGameMin(baseBuilder);
    }

    public void sendMsgToGameMin(Base.Builder baseBuilder) {
        GameContext.sendMsgToGameMin(ctx, baseBuilder);
    }

}
