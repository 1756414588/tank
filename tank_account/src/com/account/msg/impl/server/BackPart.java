package com.account.msg.impl.server;

import java.util.List;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.msg.impl.php.PhpMsgManager;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.CommonPb.Part;
import com.game.pb.InnerPb.BackPartRq;
import com.game.pb.InnerPb.BackPartRs;

@Component
public class BackPart implements MessageBase {

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        BackPartRq msg = (BackPartRq) req;

        String marking = msg.getMarking();
        JSONObject json = new JSONObject();
        List<Part> partList = msg.getPartList();

        JSONArray phpMsg = new JSONArray();
        for (Part part : partList) {
            json.put("keyId", part.getKeyId());
            json.put("partId", part.getPartId());
            json.put("upLv", part.getUpLv());
            json.put("refitLv", part.getRefitLv());
            json.put("pos", part.getPos());
            phpMsg.add(json);
        }

        PhpMsgManager.getInstance().addMultipleMsg(marking, phpMsg);

        BackPartRs.Builder rsBuilder = BackPartRs.newBuilder();
        builder.setExtension(BackPartRs.ext, rsBuilder.build());
        return GameError.OK;
    }

}
