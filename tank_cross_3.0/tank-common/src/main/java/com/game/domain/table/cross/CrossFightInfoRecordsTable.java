package com.game.domain.table.cross;

import com.game.pb.CommonPb;
import com.game.pb.SerializePb;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/12 15:38
 * @description：战斗记录和战报
 */
@Table(value = "cross_fight_records_table", fetch = Table.FeatchType.START)
public class CrossFightInfoRecordsTable implements KeyDataEntity<Integer> {

    @Primary
    @Foreign
    @Column(value = "cross_id", comment = "跨服id")
    private int crossId;

    @Column(value = "records", length = -1, comment = "记录")
    private byte[] records;

    @Column(value = "rptAtks", length = -1, comment = "战报")
    private byte[] rptAtks;

    public int getCrossId() {
        return crossId;
    }

    public void setCrossId(int crossId) {
        this.crossId = crossId;
    }

    public byte[] getRecords() {
        return records;
    }

    public void setRecords(byte[] records) {
        this.records = records;
    }

    public byte[] getRptAtks() {
        return rptAtks;
    }

    public void setRptAtks(byte[] rptAtks) {
        this.rptAtks = rptAtks;
    }

    /**
     * 序列化战斗记录 序列化
     *
     * @param crossRecords
     * @return
     */
    public byte[] serCrossRecords(Collection<CommonPb.CrossRecord> crossRecords) {
        SerializePb.SerCrossRecords.Builder ser = SerializePb.SerCrossRecords.newBuilder();
        ser.addAllCrossRecord(crossRecords);
        return ser.build().toByteArray();
    }

    /**
     * 序列化战报 序列化
     *
     * @return
     */
    public byte[] serCrossRptAtks(Collection<CommonPb.CrossRptAtk> crossRptAtks) {
        SerializePb.SerCrossRptAtks.Builder ser = SerializePb.SerCrossRptAtks.newBuilder();
        ser.addAllCrossRptAtk(crossRptAtks);
        return ser.build().toByteArray();
    }

    /**
     * 记录 反序列化
     *
     * @return
     * @throws InvalidProtocolBufferException
     */
    public LinkedHashMap<Integer, CommonPb.CrossRecord> dserCrossRecrods()
            throws InvalidProtocolBufferException {
        LinkedHashMap<Integer, CommonPb.CrossRecord> crossRecords = new LinkedHashMap<>();

        if (records == null) {
            return crossRecords;
        }
        SerializePb.SerCrossRecords ser = SerializePb.SerCrossRecords.parseFrom(records);
        for (CommonPb.CrossRecord a : ser.getCrossRecordList()) {
            crossRecords.put(a.getReportKey(), a);
        }
        return crossRecords;
    }

    /**
     * 战报 反序列化
     *
     * @return
     * @throws InvalidProtocolBufferException
     */
    public Map<Integer, CommonPb.CrossRptAtk> dserCrossRptAtks()
            throws InvalidProtocolBufferException {

        Map<Integer, CommonPb.CrossRptAtk> crossRptAtks = new HashMap<>();

        if (rptAtks == null) {
            return crossRptAtks;
        }

        SerializePb.SerCrossRptAtks ser = SerializePb.SerCrossRptAtks.parseFrom(rptAtks);

        for (CommonPb.CrossRptAtk a : ser.getCrossRptAtkList()) {
            crossRptAtks.put(a.getReportKey(), a);
        }
        return crossRptAtks;
    }
}
