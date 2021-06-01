package com.account.msg.impl.server;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.ManageService;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.InnerPb.ServerErrorLogRq;

import net.sf.json.JSONObject;

@Component
public class ServerErrorLog implements MessageBase {

    @Autowired
    private ManageService manageService;

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        ServerErrorLogRq rq = (ServerErrorLogRq) req;

        return manageService.sererErrorLog(rq);
    }

}
