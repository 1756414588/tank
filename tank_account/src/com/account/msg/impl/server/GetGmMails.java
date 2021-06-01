package com.account.msg.impl.server;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.GmMailService;
import com.account.util.MessageHelper;
import com.game.pb.BasePb.Base.Builder;

@Component
public class GetGmMails implements MessageBase {

    @Autowired
    private GmMailService gmMailService;

    @Override
    public JSONObject execute(JSONObject request) {
        JSONObject back = MessageHelper.createPacket(MessageHelper.getRequestCmd(request));
        JSONObject param = MessageHelper.getRequestParam(request);
        JSONObject response = new JSONObject();
        GameError gameError;
        //LOG.error("getGmMailList");
        if (param == null) {
            gameError = GameError.PARAM_ERROR;
            return MessageHelper.packError(back, gameError);
        }
        gameError = gmMailService.getGmMails(response);
        return MessageHelper.packResponse(back, gameError, response);
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        return null;
    }
}
