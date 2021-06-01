package com.game.domain.table.crossmine;

import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;

/**
 * @author yeding
 * @create 2019/6/18 14:02
 * @decs
 */
@Table(value = "cross_mine_army", fetch = Table.FeatchType.USE)
public class CrossMineAmryTable implements KeyDataEntity<Integer> {


    @Primary
    @Foreign
    @Column(value = "id", comment = "id")
    private int id;

    @Column(value = "army_info", comment = "存放对应矿点的驻守信息")
    private byte[] armyInfo;

    @Column(value = "player_rank_info", comment = "存放具体积分信息")
    private byte[] playerRankInfo;

    @Column(value = "server_rank_info", comment = "存放服务器积分排名信息")
    private byte[] serversRankScore;

    @Column(value = "getInfo", comment = "服务器排行领取过的玩家id")
    private byte[] getInfo;


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public byte[] getArmyInfo() {
        return armyInfo;
    }

    public void setArmyInfo(byte[] armyInfo) {
        this.armyInfo = armyInfo;
    }

    public byte[] getPlayerRankInfo() {
        return playerRankInfo;
    }

    public void setPlayerRankInfo(byte[] playerRankInfo) {
        this.playerRankInfo = playerRankInfo;
    }

    public byte[] getServersRankScore() {
        return serversRankScore;
    }

    public void setServersRankScore(byte[] serversRankScore) {
        this.serversRankScore = serversRankScore;
    }

    public byte[] getGetInfo() {
        return getInfo;
    }

    public void setGetInfo(byte[] getInfo) {
        this.getInfo = getInfo;
    }
}
