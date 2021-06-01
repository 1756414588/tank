package com.game.crossserver.server;

import com.game.message.handler.cs.cross.*;
import com.game.message.handler.cs.crossParty.*;
import com.game.message.pool.MessagePool;
import com.game.pb.CrossGamePb;
import com.game.util.LogUtil;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 14:49
 * @description：
 */
public class CrossMessagePool extends MessagePool {
    @Override
    protected void register() {
        try {
            // 跨服战
            registerC(CrossGamePb.CCGameServerRegRq.EXT_FIELD_NUMBER, CrossGamePb.CCGameServerRegRs.EXT_FIELD_NUMBER, CCGameServerRegHandler.class);
            registerC(CrossGamePb.CCGetCrossServerListRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossServerListRs.EXT_FIELD_NUMBER, CCGetCrossServerListHandler.class);
            registerC(CrossGamePb.CCGetCrossFightStateRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossFightStateRs.EXT_FIELD_NUMBER, CCGetCrossFightStateHandler.class);
            registerC(CrossGamePb.CCCrossFightRegRq.EXT_FIELD_NUMBER, CrossGamePb.CCCrossFightRegRs.EXT_FIELD_NUMBER, CCCrossFightRegHandler.class);
            registerC(CrossGamePb.CCGetCrossRegInfoRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossRegInfoRs.EXT_FIELD_NUMBER, CCGetCrossRegInfoHandler.class);
            registerC(CrossGamePb.CCCancelCrossRegRq.EXT_FIELD_NUMBER, CrossGamePb.CCCancelCrossRegRs.EXT_FIELD_NUMBER, CCCancelCrossRegHandler.class);
            registerC(CrossGamePb.CCGetCrossFormRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossFormRs.EXT_FIELD_NUMBER, CCGetCrossFormHandler.class);
            registerC(CrossGamePb.CCSetCrossFormRq.EXT_FIELD_NUMBER, CrossGamePb.CCSetCrossFormRs.EXT_FIELD_NUMBER, CCSetCrossFormHandler.class);
            registerC(CrossGamePb.CCGetCrossPersonSituationRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossPersonSituationRs.EXT_FIELD_NUMBER, CCGetCrossPersonSituationHandler.class);
            registerC(CrossGamePb.CCGetCrossJiFenRankRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossJiFenRankRs.EXT_FIELD_NUMBER, CCGetCrossJiFenRankHandler.class);
            registerC(CrossGamePb.CCGetCrossReportRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossReportRs.EXT_FIELD_NUMBER, CCGetCrossReportHandler.class);
            registerC(CrossGamePb.CCGetCrossKnockCompetInfoRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossKnockCompetInfoRs.EXT_FIELD_NUMBER, CCGetCrossKnockCompetInfoHandler.class);
            registerC(CrossGamePb.CCGetCrossFinalCompetInfoRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossFinalCompetInfoRs.EXT_FIELD_NUMBER, CCGetCrossFinalCompetInfoHandler.class);
            registerC(CrossGamePb.CCBetBattleRq.EXT_FIELD_NUMBER, CrossGamePb.CCBetBattleRs.EXT_FIELD_NUMBER, CCBetBattleHandler.class);
            registerC(CrossGamePb.CCBetRollBackRq.EXT_FIELD_NUMBER, 0, CCBetRollBackHandler.class);
            registerC(CrossGamePb.CCGetMyBetRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetMyBetRs.EXT_FIELD_NUMBER, CCGetMyBetHandler.class);
            registerC(CrossGamePb.CCReceiveBetRq.EXT_FIELD_NUMBER, CrossGamePb.CCReceiveBetRs.EXT_FIELD_NUMBER, CCReceiveBetHandler.class);
            registerC(CrossGamePb.CCGetCrossShopRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossShopRs.EXT_FIELD_NUMBER, CCGetCrossShopHandler.class);
            registerC(CrossGamePb.CCExchangeCrossShopRq.EXT_FIELD_NUMBER, CrossGamePb.CCExchangeCrossShopRs.EXT_FIELD_NUMBER, CCExchangeCrossShopHandler.class);
            registerC(CrossGamePb.CCGetCrossFinalRankRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossFinalRankRs.EXT_FIELD_NUMBER, CCGetCrossFinalRankHandler.class);
            registerC(CrossGamePb.CCReceiveRankRwardRq.EXT_FIELD_NUMBER, CrossGamePb.CCReceiveRankRwardRs.EXT_FIELD_NUMBER, CCReceiveRankRwardHandler.class);
            registerC(CrossGamePb.CCGetCrossTrendRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossTrendRs.EXT_FIELD_NUMBER, CCGetCrossTrendHanlder.class);
            registerC(CrossGamePb.CCHeartRq.EXT_FIELD_NUMBER, 0, CCHeartHandler.class);
            registerC(CrossGamePb.CCGMSetCrossFormRq.EXT_FIELD_NUMBER, 0, CCGMSetCrossFormHanlder.class);
            registerC(CrossGamePb.CCGmSynCrossLashRankRq.EXT_FIELD_NUMBER, 0, CCGmSynCrossLashRankHanlder.class);
            registerC(CrossGamePb.CCGMAddJiFenRq.EXT_FIELD_NUMBER, 0, CCGMAddJiFenHanlder.class);
            // 跨服军团战
            registerC(CrossGamePb.CCGetCrossPartyStateRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossPartyStateRs.EXT_FIELD_NUMBER, CCGetCrossPartyStateHandler.class);
            registerC(CrossGamePb.CCGetCrossPartyServerListRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossPartyServerListRs.EXT_FIELD_NUMBER, CCGetCrossPartyServerListHandler.class);
            registerC(CrossGamePb.CCCrossPartyRegRq.EXT_FIELD_NUMBER, CrossGamePb.CCCrossPartyRegRs.EXT_FIELD_NUMBER, CCCrossPartyRegHandler.class);
            registerC(CrossGamePb.CCGetCrossPartyMemberRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossPartyMemberRs.EXT_FIELD_NUMBER, CCGetCrossPartyMemberHandler.class);
            registerC(CrossGamePb.CCGetCrossPartyRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCrossPartyRs.EXT_FIELD_NUMBER, CCGetCrossPartyHandler.class);
            registerC(CrossGamePb.CCGetCPFormRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCPFormRs.EXT_FIELD_NUMBER, CCGetCPFormHandler.class);
            registerC(CrossGamePb.CCSetCPFormRq.EXT_FIELD_NUMBER, CrossGamePb.CCSetCPFormRs.EXT_FIELD_NUMBER, CCSetCPFormHandler.class);
            registerC(CrossGamePb.CCGetCPSituationRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCPSituationRs.EXT_FIELD_NUMBER, CCGetCPSituationHandler.class);
            registerC(CrossGamePb.CCGetCPOurServerSituationRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCPOurServerSituationRs.EXT_FIELD_NUMBER, CCGetCPOurServerSituationHandler.class);
            registerC(CrossGamePb.CCGetCPReportRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCPReportRs.EXT_FIELD_NUMBER, CCGetCPReportHandler.class);
            registerC(CrossGamePb.CCGetCPRankRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCPRankRs.EXT_FIELD_NUMBER, CCGetCPRankHandler.class);
            registerC(CrossGamePb.CCReceiveCPRewardRq.EXT_FIELD_NUMBER, CrossGamePb.CCReceiveCPRewardRs.EXT_FIELD_NUMBER, CCReceiveCPRewardHandler.class);
            registerC(CrossGamePb.CCGetCPMyRegInfoRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCPMyRegInfoRs.EXT_FIELD_NUMBER, CCGetCPMyRegInfoHandler.class);
            registerC(CrossGamePb.CCGMSetCPFormRq.EXT_FIELD_NUMBER, 0, CCGMSetCPFormHandler.class);
            registerC(CrossGamePb.CCGetCPShopRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCPShopRs.EXT_FIELD_NUMBER, CCGetCPShopHandler.class);
            registerC(CrossGamePb.CCExchangeCPShopRq.EXT_FIELD_NUMBER, CrossGamePb.CCExchangeCPShopRs.EXT_FIELD_NUMBER, CCExchangeCPShopHandler.class);
            registerC(CrossGamePb.CCGetCPTrendRq.EXT_FIELD_NUMBER, CrossGamePb.CCGetCPTrendRs.EXT_FIELD_NUMBER, CCGetCPTrendHandler.class);
            registerC(CrossGamePb.CCCanQuitPartyRq.EXT_FIELD_NUMBER, CrossGamePb.CCCanQuitPartyRs.EXT_FIELD_NUMBER, CCCanQuitPartyHandler.class);

        } catch (Exception e) {
            LogUtil.error(e);
        }
    }
}
