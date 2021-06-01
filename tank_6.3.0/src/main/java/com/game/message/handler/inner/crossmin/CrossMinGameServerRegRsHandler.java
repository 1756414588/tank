package com.game.message.handler.inner.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGameServerRegRs;
import com.game.pb.CrossMinPb;
import com.game.server.CrossMinContext;
import com.game.util.LogHelper;
import com.game.util.LogUtil;

public class CrossMinGameServerRegRsHandler extends InnerHandler {

    @Override
    public void action() {
        CrossMinPb.CrossMinGameServerRegRs rs = msg.getExtension(CrossMinPb.CrossMinGameServerRegRs.ext);
        LogUtil.crossInfo("crossMin 收到跨服 {} 注册成功消息 crossMin  crossServerId={},crossName={}", rs.getConnectType(), rs.getCrossServerName(), rs.getCrossServerId());

        if ("socket".equals(rs.getConnectType())) {
            CrossMinContext.setCrossMinSocket(true);
        }

        if ("rpc".equals(rs.getConnectType())) {
            CrossMinContext.setCrossMinRpc(true);
        }

        if (CrossMinContext.isCrossMinRpc() && CrossMinContext.isCrossMinSocket()) {
            LogUtil.crossInfo("crossMin 注册成功");
        }
    }

}
