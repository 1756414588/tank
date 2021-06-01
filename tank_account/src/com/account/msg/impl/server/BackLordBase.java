package com.account.msg.impl.server;

import java.util.List;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.msg.impl.php.PhpMsgManager;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.CommonPb.TwoInt;
import com.game.pb.InnerPb.BackLordBaseRq;
import com.game.pb.InnerPb.BackLordBaseRs;

@Component
public class BackLordBase implements MessageBase {

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        BackLordBaseRq msg = (BackLordBaseRq) req;

        String marking = msg.getMarking();
        List<TwoInt> list = msg.getTowIntList();
        JSONArray phpMsg = new JSONArray();
        for (TwoInt twoInt : list) {
            if (twoInt.getV2() == 0 || twoInt.getV1() == 0) {
                continue;
            }
            JSONObject json = new JSONObject();
            json.put("id", twoInt.getV1());
            json.put("count", twoInt.getV2());
            phpMsg.add(json);
        }

        PhpMsgManager.getInstance().addMultipleMsg(marking, phpMsg);

        BackLordBaseRs.Builder rsBuilder = BackLordBaseRs.newBuilder();
        builder.setExtension(BackLordBaseRs.ext, rsBuilder.build());
        return GameError.OK;
    }

}
