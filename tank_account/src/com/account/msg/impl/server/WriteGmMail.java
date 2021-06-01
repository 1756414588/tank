package com.account.msg.impl.server;

import java.util.Date;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.GmMailService;
import com.account.util.DateHelper;
import com.account.util.MessageHelper;
import com.game.pb.BasePb.Base.Builder;

@Component
public class WriteGmMail implements MessageBase {

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
            int type = param.getInt("type");
            String gmName = "报告军师运营团队";
            String title = param.getString("title");
            String content = param.getString("content");
            String params = "[]";
            int condition = 0;
            int conditionType = 0;
            int conditionValue = 0;
            if (param.containsKey("gmName")) {
                gmName = param.getString("gmName");
            }
            if (param.containsKey("param")) {
                params = param.getString("param");
            }
            if (param.containsKey("condition")) {
                condition = param.getInt("condition");
            }
            if (param.containsKey("conditionType")) {
                conditionType = param.getInt("conditionType");
            }
            if (param.containsKey("conditionValue")) {
                conditionValue = param.getInt("conditionValue");
            }
            String awards = param.getString("awards");
            String beginDate = param.getString("beginDate");
            String endDate = param.getString("endDate");
            Long alive = param.getLong("alive");
            int delModel = param.getInt("delModel");

            Date dateBegin = DateHelper.parseDate(beginDate);
            Date dateEndDate = DateHelper.parseDate(endDate);
            gameError = gmMailService.writeGmMail(type, gmName, title, content, params, condition, conditionType, conditionValue, awards, dateBegin.getTime(),
                    dateEndDate.getTime(), alive, delModel, response);
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
