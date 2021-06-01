package com.account.msg.impl.server;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.ManageService;
import com.account.util.MessageHelper;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb.RegisterRq;
import com.game.pb.InnerPb.RegisterRs;

@Component
public class RegisterServer implements MessageBase {

    @Autowired
    private ManageService manageService;

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        JSONObject back = MessageHelper.createPacket(MessageHelper.getRequestCmd(request));
        JSONObject param = MessageHelper.getRequestParam(request);
        JSONObject response = new JSONObject();
        GameError gameError;
        if (param == null) {
            gameError = GameError.PARAM_ERROR;
            return MessageHelper.packError(back, gameError);
        }
        gameError = manageService.registerServer(param);
        return MessageHelper.packResponse(back, gameError, response);
    }

    @Override
    public GameError execute(Object req, Base.Builder builder) {
        // TODO Auto-generated method stub
        RegisterRq msg = (RegisterRq) req;
        RegisterRs.Builder rsBuilder = RegisterRs.newBuilder();

        GameError gameError = manageService.registerServer(msg, rsBuilder);

        RegisterRs rs = rsBuilder.build();
        builder.setExtension(RegisterRs.ext, rs);
        return gameError;
    }

}
