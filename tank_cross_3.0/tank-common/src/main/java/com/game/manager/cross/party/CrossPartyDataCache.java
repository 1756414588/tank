package com.game.manager.cross.party;

import com.game.crossParty.domain.GroupParty;
import com.game.crossParty.domain.Party;
import com.game.crossParty.domain.PartyMember;
import com.game.crossParty.domain.ServerSisuation;
import com.game.pb.CommonPb;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/14 15:43
 * @description：
 */
public class CrossPartyDataCache {

    private static final LinkedHashMap<String, PartyMember> partyMembers = new LinkedHashMap<String, PartyMember>();

    private static final LinkedHashMap<String, Party> partys = new LinkedHashMap<String, Party>();

    private static final Map<Integer, GroupParty> groupMap = new HashMap<Integer, GroupParty>();

    private static final LinkedHashMap<String, String> lianShengRank = new LinkedHashMap<String, String>();

    private static final Map<Integer, ServerSisuation> serverSisuationMap = new HashMap<Integer, ServerSisuation>();

    private static final LinkedHashMap<Integer, CommonPb.CPRecord> crossRecords = new LinkedHashMap<Integer, CommonPb.CPRecord>();

    private static final Map<Integer, CommonPb.CPRptAtk> crossRptAtks = new HashMap<Integer, CommonPb.CPRptAtk>();

    public static LinkedHashMap<String, PartyMember> getPartyMembers() {
        return partyMembers;
    }

    public static LinkedHashMap<String, Party> getPartys() {
        return partys;
    }

    public static Map<Integer, GroupParty> getGroupMap() {
        return groupMap;
    }

    public static LinkedHashMap<String, String> getLianShengRank() {
        return lianShengRank;
    }

    public static Map<Integer, ServerSisuation> getServerSisuationMap() {
        return serverSisuationMap;
    }

    public static LinkedHashMap<Integer, CommonPb.CPRecord> getCrossRecords() {
        return crossRecords;
    }

    public static Map<Integer, CommonPb.CPRptAtk> getCrossRptAtks() {
        return crossRptAtks;
    }
}
