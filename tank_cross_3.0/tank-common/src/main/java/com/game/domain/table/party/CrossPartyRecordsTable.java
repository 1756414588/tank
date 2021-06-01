package com.game.domain.table.party;

import com.game.pb.CommonPb;
import com.game.pb.SerializePb;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 战斗记录 和战报 @Author: hezhi @Date: 2019/3/11 17:49
 */
@Table(value = "cross_party_records_table", fetch = Table.FeatchType.START)
public class CrossPartyRecordsTable implements KeyDataEntity<Integer> {

    @Primary
    @Foreign
    @Column(value = "cross_id")
    private int crossId;

    @Column(value = "crossRecords_info", length = -1, comment = "战斗记录")
    private byte[] crossRecordsInfo;

    @Column(value = "crossRptAtks_info", length = -1, comment = "战报记录")
    private byte[] crossRptAtksInfo;

    public int getCrossId() {
        return crossId;
    }

    public void setCrossId(int crossId) {
        this.crossId = crossId;
    }

    public byte[] getCrossRecordsInfo() {
        return crossRecordsInfo;
    }

    public void setCrossRecordsInfo(byte[] crossRecordsInfo) {
        this.crossRecordsInfo = crossRecordsInfo;
    }

    public byte[] getCrossRptAtksInfo() {
        return crossRptAtksInfo;
    }

    public void setCrossRptAtksInfo(byte[] crossRptAtksInfo) {
        this.crossRptAtksInfo = crossRptAtksInfo;
    }

    public byte[] serCrossRecords(LinkedHashMap<Integer, CommonPb.CPRecord> crossRecords) {
        SerializePb.SerCPRecords.Builder ser = SerializePb.SerCPRecords.newBuilder();
        ser.addAllCpRecord(crossRecords.values());
        return ser.build().toByteArray();
    }

    public LinkedHashMap<Integer, CommonPb.CPRecord> dserCrossRecrods()
            throws InvalidProtocolBufferException {

        LinkedHashMap<Integer, CommonPb.CPRecord> crossRecords =
                new LinkedHashMap<Integer, CommonPb.CPRecord>();
        if (crossRecordsInfo == null) {
            return crossRecords;
        }

        SerializePb.SerCPRecords ser = SerializePb.SerCPRecords.parseFrom(crossRecordsInfo);

        for (CommonPb.CPRecord a : ser.getCpRecordList()) {
            crossRecords.put(a.getReportKey(), a);
        }

        return crossRecords;
    }

    public byte[] serCrossRptAtks(Map<Integer, CommonPb.CPRptAtk> crossRptAtks) {
        SerializePb.SerCPRptAtks.Builder ser = SerializePb.SerCPRptAtks.newBuilder();
        ser.addAllCpRptAtk(crossRptAtks.values());
        return ser.build().toByteArray();
    }

    public Map<Integer, CommonPb.CPRptAtk> dserCrossRptAtks() throws InvalidProtocolBufferException {

        Map<Integer, CommonPb.CPRptAtk> crossRptAtks = new HashMap<Integer, CommonPb.CPRptAtk>();
        if (crossRptAtksInfo == null) {
            return crossRptAtks;
        }

        SerializePb.SerCPRptAtks ser = SerializePb.SerCPRptAtks.parseFrom(crossRptAtksInfo);
        for (CommonPb.CPRptAtk a : ser.getCpRptAtkList()) {
            crossRptAtks.put(a.getReportKey(), a);
        }
        return crossRptAtks;
    }
}
