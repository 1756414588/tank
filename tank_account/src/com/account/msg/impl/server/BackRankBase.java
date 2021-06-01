package com.account.msg.impl.server;

import java.util.List;

import org.springframework.stereotype.Component;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.msg.impl.php.PhpMsgManager;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.CommonPb.RankData;
import com.game.pb.InnerPb.BackRankBaseRq;
import com.game.pb.InnerPb.BackRankBaseRs;

@Component
public class BackRankBase implements MessageBase {

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        BackRankBaseRq msg = (BackRankBaseRq) req;

        String marking = msg.getMarking();
        List<RankData> list = msg.getRankDataList();
        JSONArray phpMsg = new JSONArray();
        for (RankData rankData : list) {
            JSONObject json = new JSONObject();
            json.put("name", rankData.getName());
            json.put("lv", rankData.getLv());
            json.put("value", rankData.getValue());
            phpMsg.add(json);
        }

        PhpMsgManager.getInstance().addMultipleMsg(marking, phpMsg);

        BackRankBaseRs.Builder rsBuilder = BackRankBaseRs.newBuilder();
        builder.setExtension(BackRankBaseRs.ext, rsBuilder.build());
        return GameError.OK;
    }

}
