package com.game.domain.table.party;

import com.game.crossParty.domain.Party;
import com.game.crossParty.domain.PartyMember;
import com.game.pb.CommonPb;
import com.game.util.PbHelper;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.LinkedHashMap;

/**
 * 工会信息 @Author: hezhi @Date: 2019/3/11 17:32
 */
@Table(value = "cross_party_data_table", fetch = Table.FeatchType.START)
public class CrossPartyDataTable implements KeyDataEntity<Integer> {

    @Primary
    @Foreign
    @Column(value = "party_id", comment = "工会id")
    private int partyId;

    @Column(value = "party_info", length = 65535, comment = "军团信息")
    private byte[] partyInfo;

    public int getPartyId() {
        return partyId;
    }

    public void setPartyId(int partyId) {
        this.partyId = partyId;
    }

    public byte[] getPartyInfo() {
        return partyInfo;
    }

    public void setPartyInfo(byte[] partyInfo) {
        this.partyInfo = partyInfo;
    }

    public byte[] serParty(Party party) {
        CommonPb.CPParty cpPartyPb = PbHelper.createCpPartyPb(party);
        return cpPartyPb.toByteArray();
    }

    public Party dserParty(LinkedHashMap<String, PartyMember> partyMembers)
            throws InvalidProtocolBufferException {

        CommonPb.CPParty cp = CommonPb.CPParty.parseFrom(partyInfo);

        int serverId = cp.getServerId();
        int order = cp.getOrder();
        int outCount = cp.getOutCount();
        int formNum = cp.getFormNum();
        int partyId = cp.getPartyId();
        String partyName = cp.getPartyName();
        int partyLv = cp.getPartyLv();
        int warRank = cp.getWarRank();
        long fight = cp.getFight();
        int group = cp.getGroup();
        boolean isFinalGroup = cp.getIsFinalGroup();
        int totalJifen = cp.getTotalJifen();

        int myPartySirPortrait = 0;
        if (cp.hasMyPartySirPortrait()) {
            myPartySirPortrait = cp.getMyPartySirPortrait();
        }

        Party p = new Party();
        p.setServerId(serverId);
        p.setOrder(order);
        p.setOutCount(outCount);
        p.setFormNum(formNum);
        p.setPartyId(partyId);
        p.setPartyName(partyName);
        p.setPartyLv(partyLv);
        p.setWarRank(warRank);
        p.setFight(fight);
        p.setGroup(group);
        p.setFinalGroup(isFinalGroup);
        p.setTotalJifen(totalJifen);
        p.setMyPartySirPortrait(myPartySirPortrait);

        for (long roleId : cp.getFightersList()) {
            p.getFighters().add(partyMembers.get(serverId + "_" + roleId));
        }

        for (long roleId : cp.getRoleIdList()) {
            p.getMembers().put(roleId, partyMembers.get(serverId + "_" + roleId));
        }
        if (cp.getPartyReportKeyCount() > 0) {
            p.getPartyReportKey().addAll(cp.getPartyReportKeyList());
        }

        return p;
    }
}
