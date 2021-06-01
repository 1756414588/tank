/**
 * @Title: ClientHandler.java
 * @Package com.game.message.handler
 * @Description:
 * @author ZhangJun
 * @date 2015年8月10日 下午12:16:21
 * @version V1.0
 */
package com.game.message.handler;

import com.game.constant.GameError;
import com.game.pb.BasePb.Base;
import com.game.server.GameServer;
import com.game.server.util.ChannelUtil;
import com.game.util.PbHelper;
import com.google.protobuf.GeneratedMessage.GeneratedExtension;

/**
 * @author ZhangJun
 * @ClassName: ClientHandler
 * @Description: 客户端消息处理器
 * @date 2015年8月10日 下午12:16:21
 */
abstract public class ClientHandler extends Handler {


    /**
     * @return Long
     * @Title: getRoleId
     * @Description: 取得当前连接上下文对应的角色编号
     */
    public Long getRoleId() {
        return ChannelUtil.getRoleId(ctx);
    }

    /**
     * <p>Title: dealType</p>
     * <p>Description: 交互类型</p>
     *
     * @return
     * @see com.game.message.handler.Handler#dealType()
     */
    @Override
    public DealType dealType() {
        return DealType.MAIN;
    }

    /**
     * @param gameError 错误枚举
     *                  void
     * @Title: sendErrorMsgToPlayer
     * @Description: 发送错误消息给客户端
     */
    public void sendErrorMsgToPlayer(GameError gameError) {
        Base.Builder baseBuilder = createRsBase(gameError.getCode());
        sendMsgToPlayer(baseBuilder);
    }

    /**
     * @Title: sendErrorMsgToPlayer
     * @Description: 发送错误消息给客户端
     * void
     * 错误号
     */
    public void sendErrorMsgCodeToPlayer(int code) {
        Base.Builder baseBuilder = createRsBase(code);
        sendMsgToPlayer(baseBuilder);
    }

    /**
     * @param ext 消息协议生成器
     * @param msg 消息内容
     *            void
     * @Title: sendMsgToPlayer
     * @Description: 发消息给客户端
     */
    public <T> void sendMsgToPlayer(GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = createRsBase(GameError.OK, ext, msg);
        sendMsgToPlayer(baseBuilder);
    }

    /**
     * @param gameError
     * @param ext
     * @param msg       void
     * @Title: sendMsgToPlayer
     * @Description: 发消息给客户端
     */
    public <T> void sendMsgToPlayer(GameError gameError, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = createRsBase(gameError, ext, msg);
        sendMsgToPlayer(baseBuilder);
    }

    /**
     * @param command 协议编号
     * @param ext     协议生成器
     * @param msg     void
     * @Title: sendMsgToCrossServer
     * @Description: 发消息到跨服服务器
     */
    public <T> void sendMsgToCrossServer(int command, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = PbHelper.createRqBase(command, null, ext, msg);
        sendMsgToCrossServer(baseBuilder);
    }

    /**
     * @param baseBuilder 协议消息
     *                    void
     * @Title: sendMsgToCrossServer
     * @Description: 发消息到跨服战服务器
     */
    private void sendMsgToCrossServer(Base.Builder baseBuilder) {
        GameServer.getInstance().sendMsgToCross(baseBuilder);
    }


    public void sendMsgToPlayer(Base.Builder baseBuilder) {
        GameServer.getInstance().sendMsgToPlayer(ctx, baseBuilder);
    }
}
