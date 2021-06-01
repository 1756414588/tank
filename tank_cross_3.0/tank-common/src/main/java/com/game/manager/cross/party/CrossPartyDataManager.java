package com.game.manager.cross.party;

import com.game.crossParty.domain.GroupParty;
import com.game.crossParty.domain.Party;
import com.game.crossParty.domain.PartyMember;
import com.game.crossParty.domain.ServerSisuation;
import com.game.dao.table.party.CrossPartyDataTableDao;
import com.game.dao.table.party.CrossPartyMemberTableDao;
import com.game.dao.table.party.CrossPartyRecordsTableDao;
import com.game.dao.table.party.CrossPartyTableDao;
import com.game.domain.table.party.CrossPartyDataTable;
import com.game.domain.table.party.CrossPartyMemberTable;
import com.game.domain.table.party.CrossPartyRecordsTable;
import com.game.domain.table.party.CrossPartyTable;
import com.game.pb.CommonPb.CPRecord;
import com.game.pb.CommonPb.CPRptAtk;
import com.game.service.cross.party.CrossPartyService;
import com.game.service.cross.party.CrossPartyService.CrossPartyGroupFight;
import com.game.util.LogUtil;
import com.google.protobuf.InvalidProtocolBufferException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Component
public class CrossPartyDataManager {
    @Autowired
    private CrossPartyDataTableDao crossPartyDataTableDao;
    @Autowired
    private CrossPartyMemberTableDao crossPartyMemberTableDao;
    @Autowired
    private CrossPartyRecordsTableDao crossPartyRecordsTableDao;
    @Autowired
    private CrossPartyTableDao crossPartyTableDao;
    @Autowired
    private CrossPartyService crossPartyService;

    /**
     * 跨服活动id
     */
    public static final int crossId = 2;

    public CrossPartyGroupFight crossPartyGroupFight;

    public void initCrossParty() {

        try {
            LogUtil.info("开始初始化 跨服军团战数据");

            CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);

            if (crossPartyTable == null) {
                crossPartyTable = new CrossPartyTable();
                crossPartyTable.setCrossId(crossId);
                crossPartyTableDao.insert(crossPartyTable);
            }

            LogUtil.info("开始初始化 跨服军团战数据 玩家信息");

            List<CrossPartyMemberTable> crossPartyMemberTableDaoAll = crossPartyMemberTableDao.findAll();
            if (crossPartyMemberTableDaoAll != null) {
                for (CrossPartyMemberTable crossPartyMemberTable : crossPartyMemberTableDaoAll) {
                    PartyMember partyMember = crossPartyMemberTable.dserPartyMember();
                    CrossPartyDataCache.getPartyMembers().put(partyMember.getKey(), partyMember);
                }
            }

            LogUtil.info("开始初始化 跨服军团战数据 军团信息");

            List<CrossPartyDataTable> crossPartyDataTableDaoAll = crossPartyDataTableDao.findAll();
            if (crossPartyDataTableDaoAll != null) {
                for (CrossPartyDataTable crossPartyDataTable : crossPartyDataTableDaoAll) {
                    Party party = crossPartyDataTable.dserParty(CrossPartyDataCache.getPartyMembers());
                    CrossPartyDataCache.getPartys().put(party.getKey(), party);
                }
            }
            LogUtil.info("开始初始化 跨服军团战数据 战斗记录数据");

            Map<Integer, GroupParty> groupPartyMap =
                    crossPartyTable.dserGroupMap(CrossPartyDataCache.getPartys());
            CrossPartyDataCache.getGroupMap().putAll(groupPartyMap);

            LinkedHashMap<String, String> dserLianShengRank = crossPartyTable.dserLianShengRank();
            CrossPartyDataCache.getLianShengRank().putAll(dserLianShengRank);

            Map<Integer, ServerSisuation> dserServerSisuationMap = crossPartyTable.dserServerSisuationMap();
            CrossPartyDataCache.getServerSisuationMap().putAll(dserServerSisuationMap);
            LogUtil.info("开始初始化 跨服军团战数据 战斗记录 和战报信息");

            CrossPartyRecordsTable crossPartyRecordsTable = crossPartyRecordsTableDao.get(crossId);
            if (crossPartyRecordsTable == null) {
                crossPartyRecordsTable = new CrossPartyRecordsTable();
                crossPartyRecordsTable.setCrossId(crossId);
                crossPartyRecordsTableDao.insert(crossPartyRecordsTable);
            }


            LinkedHashMap<Integer, CPRecord> dserCrossRecrods = crossPartyRecordsTable.dserCrossRecrods();
            if (dserCrossRecrods != null) {
                CrossPartyDataCache.getCrossRecords().putAll(dserCrossRecrods);
            }

            Map<Integer, CPRptAtk> cpRptAtkMap = crossPartyRecordsTable.dserCrossRptAtks();
            if (cpRptAtkMap != null) {
                CrossPartyDataCache.getCrossRptAtks().putAll(cpRptAtkMap);
            }

            LogUtil.info(" 跨服军团战数据初始化完成");

            LogUtil.info("军团积分排序");
            crossPartyService.sortPartyRank();
            LogUtil.info("军团积分排序 完成");
            LogUtil.info("连胜排序");
            crossPartyService.sortLianShengRank();
            LogUtil.info("连胜排序 完成");
            LogUtil.info("个人排行排序");
            // 小组赛完成刷新更新排行榜
            crossPartyService.sortMapByJifen(CrossPartyDataCache.getPartyMembers());
            LogUtil.info("个人排行完成");
        } catch (InvalidProtocolBufferException e) {
            LogUtil.error("跨服军团站初始化出错", e);
        }
    }

    /**
     * 判断是否报名过
     *
     * @param serverId
     * @param roleId
     * @return
     */
    public boolean isReg(int serverId, long roleId) {
        return CrossPartyDataCache.getPartyMembers().containsKey(serverId + "_" + roleId);
    }

    /**
     * 报名,存入数据
     *
     * @param member
     */
    public void partyReg(PartyMember member, int partyLv, int warRank, int myPartySirPortrait) {
        CrossPartyDataCache.getPartyMembers().put(member.getServerId() + "_" + member.getRoleId(), member);
        CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(member.getRoleId());
        if (crossPartyMemberTable == null) {
            crossPartyMemberTable = new CrossPartyMemberTable();
            crossPartyMemberTable.setRoleId(member.getRoleId());
            crossPartyMemberTable.setServerId(member.getServerId());
            crossPartyMemberTable.setPartyId(member.getPartyId());
            crossPartyMemberTableDao.insert(crossPartyMemberTable);
        }

        byte[] bytes = crossPartyMemberTable.serPartyMembers(member);
        crossPartyMemberTable.setMemberInfo(bytes);
        crossPartyMemberTableDao.update(crossPartyMemberTable);

        // 存入到warParty
        addMemberToWarParty(member, partyLv, warRank, myPartySirPortrait);
    }

    private void addMemberToWarParty(PartyMember member, int partyLv, int warRank, int myPartySirPortrait) {
        Party party = CrossPartyDataCache.getPartys().get(member.getServerId() + "_" + member.getPartyId());
        if (party == null) {
            party = new Party();
            party.setServerId(member.getServerId());
            party.setPartyId(member.getPartyId());
            party.setPartyName(member.getPartyName());
            party.setPartyLv(partyLv);
            party.setWarRank(warRank);
            party.setMyPartySirPortrait(myPartySirPortrait);
            CrossPartyDataCache.getPartys().put(party.getServerId() + "_" + party.getPartyId(), party);
        }
        party.getMembers().put(member.getRoleId(), member);

        CrossPartyDataTable crossPartyDataTable = crossPartyDataTableDao.get(party.getPartyId());

        if (crossPartyDataTable == null) {
            crossPartyDataTable = new CrossPartyDataTable();
            crossPartyDataTable.setPartyId(party.getPartyId());
            crossPartyDataTableDao.insert(crossPartyDataTable);
        }

        byte[] bytes = crossPartyDataTable.serParty(party);
        crossPartyDataTable.setPartyInfo(bytes);
        crossPartyDataTableDao.update(crossPartyDataTable);
    }

    /**
     * 军团是否报名
     *
     * @param serverId
     * @param partyId
     * @return
     */
    public boolean isRegParty(int serverId, int partyId) {
        return CrossPartyDataCache.getPartys().containsKey(serverId + "_" + partyId);
    }

    /**
     * 重新计算军团战力
     *
     * @param serverId
     * @param partyId
     */
    public void caluPartyFight(int serverId, int partyId) {
        Party p = CrossPartyDataCache.getPartys().get(serverId + "_" + partyId);
        if (p != null) {
            long fight = 0;
            Iterator<PartyMember> its = p.getMembers().values().iterator();
            while (its.hasNext()) {
                fight += its.next().getFight();
            }
            p.setFight(fight);

            CrossPartyDataTable crossPartyDataTable = crossPartyDataTableDao.get(p.getPartyId());
            byte[] bytes = crossPartyDataTable.serParty(p);
            crossPartyDataTable.setPartyInfo(bytes);
            crossPartyDataTableDao.update(crossPartyDataTable);
        }
    }

    public void addCPRecord(CPRecord record) {
        if (record != null) {
            CrossPartyDataCache.getCrossRecords().put(record.getReportKey(), record);

            CrossPartyRecordsTable crossPartyRecordsTable = crossPartyRecordsTableDao.get(crossId);
            byte[] bytes = crossPartyRecordsTable.serCrossRecords(CrossPartyDataCache.getCrossRecords());
            crossPartyRecordsTable.setCrossRecordsInfo(bytes);
            crossPartyRecordsTableDao.update(crossPartyRecordsTable);
        }
    }

    public void addCPRptAtk(CPRptAtk atk) {
        if (atk != null) {

            CrossPartyDataCache.getCrossRptAtks().put(atk.getReportKey(), atk);
            CrossPartyRecordsTable crossPartyRecordsTable = crossPartyRecordsTableDao.get(crossId);
            byte[] bytes = crossPartyRecordsTable.serCrossRptAtks(CrossPartyDataCache.getCrossRptAtks());
            crossPartyRecordsTable.setCrossRptAtksInfo(bytes);
            crossPartyRecordsTableDao.update(crossPartyRecordsTable);
        }
    }
}
