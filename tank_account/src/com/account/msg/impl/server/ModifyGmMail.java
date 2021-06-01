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
public class ModifyGmMail implements MessageBase {

    @Autowired
    private GmMailService gmMailService;

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

        try {
            String ae = param.getString("ae");
            int type = param.getInt("type");
            String title = param.getString("title");
            String content = param.getString("content");
            String awards = param.getString("awards");
            long beginDate = param.getLong("beginDate");
            long endDate = param.getLong("endDate");
            Long alive = param.getLong("alive");
            int delModel = param.getInt("delModel");
            gameError = gmMailService.modifyGmMail(ae, type, title, content, awards, beginDate, endDate, alive, delModel, response);
        } catch (Exception e) {
            gameError = GameError.PARAM_ERROR;
            return MessageHelper.packError(back, gameError);
        }

        return MessageHelper.packResponse(back, gameError, response);
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        return null;
    }

}
