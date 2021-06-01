package com.account.msg.impl.server;

import java.util.List;

import org.springframework.stereotype.Component;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.msg.impl.php.PhpMsgManager;
import com.game.pb.BasePb.Base.Builder;
import com.game.pb.CommonPb.PartyMember;
import com.game.pb.InnerPb.BackPartyMembersRq;
import com.game.pb.InnerPb.BackPartyMembersRs;

@Component
public class BackPartyMembers implements MessageBase {

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public GameError execute(Object req, Builder builder) {
        BackPartyMembersRq msg = (BackPartyMembersRq) req;

        String marking = msg.getMarking();
        List<PartyMember> list = msg.getPartyMemberList();
        JSONArray phpMsg = new JSONArray();
        for (PartyMember partyMember : list) {
            JSONObject json = new JSONObject();
            json.put("name", partyMember.getNick());
            json.put("id", partyMember.getLordId());
            json.put("lv", partyMember.getLevel());
            json.put("job", partyMember.getJob());
            json.put("fight", partyMember.getFight());
            phpMsg.add(json);
        }

        PhpMsgManager.getInstance().addMultipleMsg(marking, phpMsg);

        BackPartyMembersRs.Builder rsBuilder = BackPartyMembersRs.newBuilder();
        builder.setExtension(BackPartyMembersRs.ext, rsBuilder.build());
        return GameError.OK;
    }

}
