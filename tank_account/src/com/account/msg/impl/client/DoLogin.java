package com.account.msg.impl.client;

import javax.annotation.PostConstruct;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.AccountService;
import com.account.util.MessageHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import com.game.pb.BasePb.Base;

@Component
public class DoLogin implements MessageBase {
    @Autowired
    private AccountService accountService;

    @PostConstruct
    public void initProtocol() {
        //LOG.error("-----------initProtocol------");
//		DoLoginPb.registerAllExtensions(MessageHandle.PB_EXTENDTION_REGISTRY);
    }


    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        JSONObject back = MessageHelper.createPacket(MessageHelper.getRequestCmd(request));
        JSONObject param = MessageHelper.getRequestParam(request);
        JSONObject response = new JSONObject();
        GameError gameError = accountService.doLogin(param, response);
        return MessageHelper.packResponse(back, gameError, response);
    }


    @Override
    public GameError execute(Object req, Base.Builder builder) {
        // TODO Auto-generated method stub
        DoLoginRq doLoginRq = (DoLoginRq) req;
        DoLoginRs.Builder rsBuilder = DoLoginRs.newBuilder();

        GameError gameError = accountService.doLogin(doLoginRq, rsBuilder);

        DoLoginRs doLoginRs = rsBuilder.build();
        builder.setExtension(DoLoginRs.ext, doLoginRs);
        return gameError;
    }
}
