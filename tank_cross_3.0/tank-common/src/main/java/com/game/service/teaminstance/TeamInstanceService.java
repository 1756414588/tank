package com.game.service.teaminstance;

import com.game.datamgr.StaticBountyDataMgr;
import com.game.domain.CrossPlayer;
import com.game.domain.s.StaticBountyStage;
import com.game.pb.CommonPb;
import com.game.pb.CrossMinPb;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
@Component
public class TeamInstanceService {

    @Autowired
    private StaticBountyDataMgr staticBountyDataMgr;

    /**
     * 判断关卡是否开启
     *
     * @param stageId
     * @return
     */
    public boolean isOpen(int stageId) {
        StaticBountyStage config = staticBountyDataMgr.getBountyStageConfig(stageId);
        List<Integer> openTime = config.getOpenTime();

        Calendar calendar = Calendar.getInstance();
        int day_of_week = calendar.get(Calendar.DAY_OF_WEEK) - 1;

        if (day_of_week == 0) {
            day_of_week = 7;
        }
        return openTime.contains(day_of_week);
    }


    /**
     * 通关
     *
     * @param teamPlayer
     * @param stageId
     */
    public void succFight(List<CommonPb.Record> recordList, int tankCount, List<Long> recordLordList, TeamPlayer teamPlayer, int stageId, boolean isSucc) {
        CrossMinPb.CrossSyncTeamFightBossRq.Builder msg = CrossMinPb.CrossSyncTeamFightBossRq.newBuilder();
        for (CommonPb.Record record : recordList) {
            msg.addRecord(record);
        }
        msg.setTankCount(tankCount);
        for (Long recordLord : recordLordList) {
            msg.addRecordLord(PbHelper.createTwoLongPb(recordLord, -1));
        }
        msg.setIsSuccess(isSucc);
        msg.setStageId(stageId);
        msg.setRoleId(teamPlayer.getCrossPlayer().getRoleId());
        MsgSender.send2Game(teamPlayer.getCrossPlayer().getServerId(), CrossMinPb.CrossSyncTeamFightBossRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSyncTeamFightBossRq.ext, msg.build());
    }

    /**
     * 更新任务数据
     *
     * @param player
     * @param taskType
     */
    public void changeTask(CrossPlayer player, int taskType, long value) {
        CrossMinPb.CrossSynTaskRq.Builder msg = CrossMinPb.CrossSynTaskRq.newBuilder();
        msg.setRoleId(0L);
        if (player != null) {
            msg.setRoleId(player.getRoleId());
        }
        msg.setComNum(value);
        msg.setTaskType(taskType);
        MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossSynTaskRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSynTaskRq.ext, msg.build());
    }


    /**
     * 更新服务器任务数据
     *
     * @param taskType
     * @param value
     */
    public void changeServerTask(int taskType, long value, List<TeamPlayer> teamPlayers) {
        CrossMinPb.CrossSynTaskRq.Builder msg = CrossMinPb.CrossSynTaskRq.newBuilder();
        msg.setRoleId(0L);
        msg.setComNum(value);
        msg.setTaskType(taskType);
        List<Integer> list = new ArrayList<>();
        if (teamPlayers != null) {
            for (TeamPlayer teamPlayer : teamPlayers) {
                if (!list.contains(teamPlayer.getCrossPlayer().getServerId())) {
                    list.add(teamPlayer.getCrossPlayer().getServerId());
                }
            }
        }
        for (Integer serId : list) {
            MsgSender.send2Game(serId, CrossMinPb.CrossSynTaskRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSynTaskRq.ext, msg.build());
        }
    }


}
