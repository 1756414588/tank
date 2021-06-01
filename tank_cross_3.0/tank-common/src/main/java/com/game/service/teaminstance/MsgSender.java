package com.game.service.teaminstance;

import com.game.constant.GameError;
import com.game.pb.BasePb;
import com.game.service.crossmin.Session;
import com.game.service.crossmin.SessionManager;
import com.game.util.LogUtil;
import com.google.protobuf.GeneratedMessage;
import sun.rmi.runtime.Log;

import java.util.List;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 15:24
 * @description：发送消息给游戏服
 */
public class MsgSender {

    public static <T> void send2Game(int serverId, int cmd, GeneratedMessage.GeneratedExtension<BasePb.Base, T> ext, T msg) {
        try {
            Session session = SessionManager.getSession(serverId);
            if (session == null) {
                LogUtil.error("send2Game Session is null serverId={},cmd={}", serverId, cmd);
                return;
            }
            BasePb.Base base = createRsBase(cmd, ext, msg);
            session.getCtx().writeAndFlush(base);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 给连上这个服的所有服发消息
     *
     * @param cmd
     * @param ext
     * @param msg
     * @param <T>
     */
    public static <T> void send2AllGame(int cmd, GeneratedMessage.GeneratedExtension<BasePb.Base, T> ext, T msg) {
        try {
            BasePb.Base base = createRsBase(cmd, ext, msg);
            List<Session> sessionMap = SessionManager.getSessionMap();
            for (Session session : sessionMap) {
                if (session.getCtx() != null) {
                    session.getCtx().writeAndFlush(base);
                }
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    private static <T> BasePb.Base createRsBase(int cmd, GeneratedMessage.GeneratedExtension<BasePb.Base, T> ext, T msg) {
        BasePb.Base.Builder baseBuilder = createRsBase(cmd, GameError.OK, ext, msg);
        return baseBuilder.build();
    }

    private static <T> BasePb.Base.Builder createRsBase(int cmd, GameError gameError, GeneratedMessage.GeneratedExtension<BasePb.Base, T> ext, T msg) {
        BasePb.Base.Builder baseBuilder = BasePb.Base.newBuilder();
        baseBuilder.setCmd(cmd);
        baseBuilder.setCode(gameError.getCode());
        if (msg != null) {
            baseBuilder.setExtension(ext, msg);
        }

        return baseBuilder;
    }

}
