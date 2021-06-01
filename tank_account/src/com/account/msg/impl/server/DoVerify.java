package com.account.msg.impl.server;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.AccountService;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb.VerifyRq;
import com.game.pb.InnerPb.VerifyRs;

@Component
public class DoVerify implements MessageBase {

    @Autowired
    private AccountService accountService;

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        //LOG.error("can do in this");
        // JSONObject back =
        // MessageHelper.createPacket(MessageHelper.getRequestCmd(request));
        // JSONObject param = MessageHelper.getRequestParam(request);
        // JSONObject response = new JSONObject();
        // GameError gameError;
        // if (param == null) {
        // gameError = GameError.PARAM_ERROR;
        // return MessageHelper.packError(back, gameError);
        // }
        // gameError = authorityService.verify(param, response);
        // return MessageHelper.packResponse(back, gameError, response);
        return null;
    }

    // @Override
    // public GameError execute(Object req, Builder builder) {
    // // TODO Auto-generated method stub
    // LOG.error("can not in this");
    // return null;
    // }

    @Override
    public GameError execute(Object req, Base.Builder builder) {
        // TODO Auto-generated method stub
        VerifyRq msg = (VerifyRq) req;
        VerifyRs.Builder rsBuilder = VerifyRs.newBuilder();

        GameError gameError = accountService.verifyPlayer(msg, rsBuilder);

        if (!GameError.OK.equals(gameError)) {
            return gameError;
        }

        VerifyRs rs = rsBuilder.build();
        builder.setExtension(VerifyRs.ext, rs);
        return gameError;
    }

}
