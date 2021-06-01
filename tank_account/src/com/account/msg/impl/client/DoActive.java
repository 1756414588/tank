package com.account.msg.impl.client;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.AccountService;
import com.account.util.MessageHelper;
import com.game.pb.AccountPb.DoActiveRq;
import com.game.pb.AccountPb.DoActiveRs;
import com.game.pb.BasePb.Base.Builder;

@Component
public class DoActive implements MessageBase {

    @Autowired
    private AccountService accountService;

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        JSONObject back = MessageHelper.createPacket(MessageHelper.getRequestCmd(request));
        JSONObject param = MessageHelper.getRequestParam(request);
        JSONObject response = new JSONObject();
        GameError gameError = accountService.doActive(param, response);
        return MessageHelper.packResponse(back, gameError, response);
    }


    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        DoActiveRq doActiveRq = (DoActiveRq) req;
        DoActiveRs.Builder rsBuilder = DoActiveRs.newBuilder();
        GameError gameError = accountService.doActive(doActiveRq, rsBuilder);

        DoActiveRs doActiveRs = rsBuilder.build();
        builder.setExtension(DoActiveRs.ext, doActiveRs);
        return gameError;
    }

}
