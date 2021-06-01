package com.account.msg.impl.server;

import net.sf.json.JSONObject;

import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.msg.impl.php.PhpMsgManager;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.InnerPb.BackBuildingRq;
import com.game.pb.InnerPb.BackBuildingRs;

@Component
public class BackBuilding implements MessageBase {

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        // TODO Auto-generated method stub
        BackBuildingRq msg = (BackBuildingRq) req;

        String marking = msg.getMarking();
        JSONObject json = new JSONObject();
        json.put("ware1", msg.getWare1());
        json.put("ware2", msg.getWare2());
        json.put("tech", msg.getTech());
        json.put("factory1", msg.getFactory1());
        json.put("factory2", msg.getFactory2());
        json.put("refit", msg.getRefit());
        json.put("command", msg.getCommand());
        json.put("workShop", msg.getWorkShop());

        PhpMsgManager.getInstance().addMsg(marking, json);

        BackBuildingRs.Builder rsBuilder = BackBuildingRs.newBuilder();
        builder.setExtension(BackBuildingRs.ext, rsBuilder.build());
        return GameError.OK;
    }

}
