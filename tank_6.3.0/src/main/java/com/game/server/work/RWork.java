/**
 * @Title: RWork.java
 * @Package com.game.server.work
 * @Description:
 * @author ZhangJun
 * @date 2015年8月3日 下午6:16:23
 * @version V1.0
 */
package com.game.server.work;

import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.GamePb1.BeginGameRq;
import com.game.pb.GamePb1.CreateRoleRq;
import com.game.pb.GamePb1.GetNamesRq;
import com.game.server.ConnectServer;
import com.game.server.GameServer;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author ZhangJun
 * @ClassName: RWork
 * @Description: 和游戏客户端通信并执行的相关逻辑的指令
 * @date 2015年8月3日 下午6:16:23
 */
public class RWork extends AbstractWork {
    private ChannelHandlerContext ctx;
    private Base msg;

    /**
     * Title:
     * Description:
     *
     * @param ctx 连接实例
     * @param msg 消息内容
     */
    public RWork(ChannelHandlerContext ctx, Base msg) {
        this.ctx = ctx;
        this.msg = msg;
    }

    /**
     * <p>Title: run</p>
     * <p>Description: 执行任务</p>
     *
     * @see java.lang.Runnable#run()
     */
    @Override
    public void run() {
        try {
            GameServer gameServer = GameServer.getInstance();
            ConnectServer connectServer = gameServer.connectServer;
            int cmd = msg.getCmd();
            ClientHandler handler = gameServer.messagePool.getClientHandler(cmd);
            if (handler == null) {
                return;
            }
            handler.setCtx(ctx);
            handler.setMsg(msg);
            if (cmd == BeginGameRq.EXT_FIELD_NUMBER || cmd == GetNamesRq.EXT_FIELD_NUMBER || cmd == CreateRoleRq.EXT_FIELD_NUMBER) {
                connectServer.actionExcutor.execute(handler);
            } else {
                gameServer.mainLogicServer.addCommand(handler);
            }
        } catch (Exception e) {
            LogUtil.error("执行玩家初始化游戏，或添加协议如队列出错", e);
        }

    }
}
