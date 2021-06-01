package com.account.msg.impl.server;

import java.util.List;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.msg.impl.php.PhpMsgManager;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.CommonPb.Equip;
import com.game.pb.InnerPb.BackEquipRq;
import com.game.pb.InnerPb.BackEquipRs;

@Component
public class BackEquip implements MessageBase {

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        BackEquipRq msg = (BackEquipRq) req;

        String marking = msg.getMarking();
        JSONObject json = new JSONObject();
        List<Equip> equipList = msg.getEquipList();

        JSONArray phpMsg = new JSONArray();
        for (Equip equip : equipList) {
            json.put("keyId", equip.getKeyId());
            json.put("lv", equip.getLv());
            json.put("equipId", equip.getEquipId());
            json.put("exp", equip.getExp());
            json.put("pos", equip.getPos());
            phpMsg.add(json);
        }

        PhpMsgManager.getInstance().addMultipleMsg(marking, phpMsg);

        BackEquipRs.Builder rsBuilder = BackEquipRs.newBuilder();
        builder.setExtension(BackEquipRs.ext, rsBuilder.build());
        return GameError.OK;
    }

}
