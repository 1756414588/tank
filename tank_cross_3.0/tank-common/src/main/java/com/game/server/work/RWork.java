package com.game.server.work;

import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.GamePb1.BeginGameRq;
import com.game.pb.GamePb1.CreateRoleRq;
import com.game.pb.GamePb1.GetNamesRq;
import com.game.server.ConnectServer;
import com.game.server.GameContext;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author ZhangJun
 * @ClassName: RWork @Description: TODO
 * @date 2015年8月3日 下午6:16:23
 */
public class RWork extends AbstractWork {
    private ChannelHandlerContext ctx;
    private Base msg;

    public RWork(ChannelHandlerContext ctx, Base msg) {
        this.ctx = ctx;
        this.msg = msg;
    }

    @Override
    public void run() {
        try {
            ConnectServer connectServer = GameContext.getConnectServer();
            int cmd = msg.getCmd();
            ClientHandler handler = GameContext.getMessagePool().getClientHandler(cmd);
            if (handler == null) {
                return;
            }

            handler.setCtx(ctx);
            handler.setMsg(msg);

            if (cmd == BeginGameRq.EXT_FIELD_NUMBER || cmd == GetNamesRq.EXT_FIELD_NUMBER || cmd == CreateRoleRq.EXT_FIELD_NUMBER) {
                connectServer.actionExcutor.execute(handler);
            } else {
                GameContext.getMainLogicServer().addCommand(handler);
            }
        } catch (Exception e) {
            LogUtil.error(e, e);
        }
    }
}
