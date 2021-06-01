package com.account.msg.impl.server;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.msg.impl.php.PhpMsgManager;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.CommonPb;
import com.game.pb.InnerPb;
import com.game.pb.InnerPb.BackBuildingRs;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class BackEnergy implements MessageBase {

    @Override
    public JSONObject execute(JSONObject request) {
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        InnerPb.BackEnergyRq msg = (InnerPb.BackEnergyRq) req;
        String marking = msg.getMarking();
        JSONObject obj = new JSONObject();
        JSONArray array = new JSONArray();
        List<CommonPb.LordEnergyInfo> infoList = msg.getInfoList();
        for (CommonPb.LordEnergyInfo lordEnergyInfo : infoList) {
            obj.put("roleId", lordEnergyInfo.getRoleId());
            obj.put("nickName", lordEnergyInfo.getNick());
            obj.put("level", lordEnergyInfo.getLevel());
            obj.put("fight", lordEnergyInfo.getFight());
            obj.put("enLevel", lordEnergyInfo.getEnLevel());
            obj.put("vip", lordEnergyInfo.getVip());
            obj.put("totalRec", lordEnergyInfo.getAllmoney());
            List<CommonPb.LordPart> partList = lordEnergyInfo.getPartList();
            JSONObject part = new JSONObject();
            JSONArray partArray = new JSONArray();
            for (CommonPb.LordPart lordPart : partList) {
                part.put("partId", lordPart.getPartId());
                part.put("upLv", lordPart.getUpLv());
                part.put("refitLv", lordPart.getRefitLv());
                part.put("smeltLv", lordPart.getSmeltLv());
                partArray.add(part);
            }
            obj.put("part", partArray);
            array.add(obj);
        }
        PhpMsgManager.getInstance().addMultipleMsg(marking, array);
        BackBuildingRs.Builder rsBuilder = BackBuildingRs.newBuilder();
        builder.setExtension(BackBuildingRs.ext, rsBuilder.build());
        return GameError.OK;
    }

}
