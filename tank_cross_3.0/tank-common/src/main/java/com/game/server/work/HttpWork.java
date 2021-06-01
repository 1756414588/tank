/**
 * @Title: HttpWork.java @Package com.game.server.work @Description: TODO
 * @author ZhangJun
 * @date 2015年11月3日 上午11:14:10
 * @version V1.0
 */
package com.game.server.work;

import com.game.pb.BasePb.Base;
import com.game.server.GameContext;
import com.game.server.HttpServer;
import com.game.util.HttpUtils;
import com.game.util.LogUtil;
import com.game.util.PbHelper;

public class HttpWork extends AbstractWork {
    private Base msg;
    private HttpServer httpServer;
    private String url;

    @Override
    public void run() {
        try {
            byte[] result = HttpUtils.sendPbByte(this.url, msg.toByteArray());

            if (result == null) {
                LogUtil.error("游戏服未连接上 " + this.url);
                return;
            }

            short len = PbHelper.getShort(result, 0);
            byte[] data = new byte[len];
            System.arraycopy(result, 2, data, 0, len);

            Base rs = Base.parseFrom(data, GameContext.registry);
            httpServer.doPublicCommand(rs);

        } catch (Exception e) {
            LogUtil.error("HttpWork send to url exception", e);
        }
    }

    /**
     * @param msg
     */
    public HttpWork(HttpServer httpServer, Base msg) {
        super();
        this.msg = msg;
        this.httpServer = httpServer;
        this.url = httpServer.accountServerUrl;
    }

    /**
     * @param msg \
     */
    public HttpWork(HttpServer httpServer, String url, Base msg) {
        super();
        this.msg = msg;
        this.httpServer = httpServer;
        this.url = url;
    }
}
