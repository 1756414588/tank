package com.account.msg.impl.client;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.AccountService;
import com.account.util.MessageHelper;
import com.game.pb.AccountPb.DoRegisterRq;
import com.game.pb.AccountPb.DoRegisterRs;
import com.game.pb.BasePb.Base.Builder;

@Component
public class DoRegister implements MessageBase {
    @Autowired
    private AccountService accountService;

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        JSONObject back = MessageHelper.createPacket(MessageHelper.getRequestCmd(request));
        JSONObject param = MessageHelper.getRequestParam(request);
        JSONObject response = new JSONObject();
        //LOG.error("int the doregister");
        GameError gameError = accountService.registerAccount(param, response);
        return MessageHelper.packResponse(back, gameError, response);
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        DoRegisterRq doRegisterRq = (DoRegisterRq) req;
        DoRegisterRs.Builder rsBuilder = DoRegisterRs.newBuilder();
        GameError gameError = accountService.registerAccount(doRegisterRq, rsBuilder);

        DoRegisterRs doRegisterRs = rsBuilder.build();
        builder.setExtension(DoRegisterRs.ext, doRegisterRs);
        return gameError;
    }

}
