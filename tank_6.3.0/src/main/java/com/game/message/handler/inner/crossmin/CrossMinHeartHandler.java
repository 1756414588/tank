package com.game.message.handler.inner.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;
import com.game.util.LogHelper;
import com.game.util.LogUtil;

public class CrossMinHeartHandler extends InnerHandler {

    @Override
    public void action() {
        CrossMinPb.CrossMinHeartRs rs = msg.getExtension(CrossMinPb.CrossMinHeartRs.ext);

        CrossMinService.hertRequestTime = System.currentTimeMillis();
        int crossServerId = rs.getCrossServerId();
        String crossServerName = rs.getCrossServerName();

        LogUtil.crossInfo("crossMin 接收到心跳回复 crossServerId={},crossServerName={}", crossServerId, crossServerName);
    }

}
