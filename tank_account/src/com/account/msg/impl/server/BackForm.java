package com.account.msg.impl.server;

import java.util.List;

import org.springframework.stereotype.Component;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.msg.impl.php.PhpMsgManager;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.CommonPb.Form;
import com.game.pb.InnerPb.BackFormRq;

@Component
public class BackForm implements MessageBase {

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        BackFormRq msg = (BackFormRq) req;

        String marking = msg.getMarking();
        JSONObject json = new JSONObject();
        List<Form> formList = msg.getFormsList();

        JSONArray phpMsg = new JSONArray();
        for (Form form : formList) {
            json.put("commander", form.getCommander());
            json.put("type", form.getType());
            json.put("p1", getTwoInt(form.getP1().getV1(), form.getP1().getV2()));
            json.put("p2", getTwoInt(form.getP2().getV1(), form.getP2().getV2()));
            json.put("p3", getTwoInt(form.getP3().getV1(), form.getP3().getV2()));
            json.put("p4", getTwoInt(form.getP4().getV1(), form.getP4().getV2()));
            json.put("p5", getTwoInt(form.getP5().getV1(), form.getP5().getV2()));
            json.put("p6", getTwoInt(form.getP6().getV1(), form.getP6().getV2()));

            phpMsg.add(json);
        }

        PhpMsgManager.getInstance().addMultipleMsg(marking, phpMsg);

        BackFormRq.Builder rsBuilder = BackFormRq.newBuilder();
        builder.setExtension(BackFormRq.ext, rsBuilder.build());
        return GameError.OK;
    }

    private JSONObject getTwoInt(int v1, int v2) {
        JSONObject jsondata = new JSONObject();
        jsondata.put("id", v1);
        jsondata.put("num", v2);
        return jsondata;
    }

}
