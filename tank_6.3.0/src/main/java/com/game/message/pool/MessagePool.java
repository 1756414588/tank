/**
 * @Title: MessagePool.java
 * @Package com.game.message.pool
 * @Description:
 * @author ZhangJun
 * @date 2015年8月3日 下午12:39:19
 * @version V1.0
 */
package com.game.message.pool;

import com.game.message.handler.ClientHandler;
import com.game.message.handler.InnerHandler;
import com.game.message.handler.ServerHandler;
import com.game.message.handler.crossmin.*;
import com.game.message.handler.crossmine.CrossAttackMineHandler;
import com.game.message.handler.crossmine.CrossAttackNpcMineHandler;
import com.game.message.handler.cs.*;
import com.game.message.handler.cs.activity.*;
import com.game.message.handler.cs.activity.medalofhonor.*;
import com.game.message.handler.cs.activity.monopoly.*;
import com.game.message.handler.cs.activity.redbag.*;
import com.game.message.handler.cs.activity.simple.*;
import com.game.message.handler.cs.ad.*;
import com.game.message.handler.cs.airship.*;
import com.game.message.handler.cs.attackEffect.GetAttackEffectHandler;
import com.game.message.handler.cs.attackEffect.UseAttackEffectHandler;
import com.game.message.handler.cs.corss.*;
import com.game.message.handler.cs.crossParty.*;
import com.game.message.handler.cs.crossmine.*;
import com.game.message.handler.cs.drill.*;
import com.game.message.handler.cs.energyStone.*;
import com.game.message.handler.cs.festival.*;
import com.game.message.handler.cs.fightlab.*;
import com.game.message.handler.cs.friend.FriendGivePropHandler;
import com.game.message.handler.cs.king.*;
import com.game.message.handler.cs.lord.GetMilitaryRankHandler;
import com.game.message.handler.cs.lord.UpMilitaryRankHandler;
import com.game.message.handler.cs.lordequip.*;
import com.game.message.handler.cs.lucky.GetActLuckyInfoRqHandler;
import com.game.message.handler.cs.lucky.GetActLuckyPoolLogHandler;
import com.game.message.handler.cs.lucky.GetActLuckyRewardRqHandler;
import com.game.message.handler.cs.medal.*;
import com.game.message.handler.cs.plugin.PlugInScoutMineValidCodeHandler;
import com.game.message.handler.cs.rebel.*;
import com.game.message.handler.cs.redplan.*;
import com.game.message.handler.cs.secretWeapon.GetSecretWeaponInfoHandler;
import com.game.message.handler.cs.secretWeapon.LockedWeaponBarHandler;
import com.game.message.handler.cs.secretWeapon.StudyWeaponSkillHandler;
import com.game.message.handler.cs.secretWeapon.UnlockWeaponBarHandler;
import com.game.message.handler.cs.shop.BuyShopGoodsHandler;
import com.game.message.handler.cs.shop.GetShopInfoHandler;
import com.game.message.handler.cs.sign.DrawMonthSignExtHandler;
import com.game.message.handler.cs.sign.GetMonthSignHandler;
import com.game.message.handler.cs.sign.MonthSignHandler;
import com.game.message.handler.cs.tactics.*;
import com.game.message.handler.cs.teaminstance.*;
import com.game.message.handler.cs.wipe.GetWipeInfoRqHandler;
import com.game.message.handler.cs.wipe.GetWipeRewarRqHandler;
import com.game.message.handler.cs.wipe.SetWipeInfoRqHandler;
import com.game.message.handler.inner.*;
import com.game.message.handler.inner.crossParty.*;
import com.game.message.handler.inner.crossmin.CrossMinGameServerRegRsHandler;
import com.game.message.handler.inner.crossmin.CrossMinHeartHandler;
import com.game.message.handler.ss.*;
import com.game.pb.AdvertisementPb.*;
import com.game.pb.CrossGamePb.*;
import com.game.pb.CrossMinPb;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb2.*;
import com.game.pb.GamePb3.*;
import com.game.pb.GamePb4.*;
import com.game.pb.GamePb5.*;
import com.game.pb.GamePb6.*;
import com.game.pb.InnerPb;
import com.game.pb.InnerPb.*;

import java.util.HashMap;

/**
 * @author ZhangJun
 * @ClassName: MessagePool
 * @Description: 消息池 所有的的协议消息的注册表 是将协议和Handler一一对应的中央控制器
 * @date 2015年8月3日 下午12:39:19
 */
public class MessagePool {
    private HashMap<Integer, Class<? extends ClientHandler>> clientHandlers = new HashMap<>();
    private HashMap<Integer, Class<? extends ServerHandler>> serverHandlers = new HashMap<>();
    private HashMap<Integer, Class<? extends InnerHandler>> innerHandlers = new HashMap<>();
    private HashMap<Integer, Integer> rsMsgCmd = new HashMap<>();

    /**
     * Title: Description: 注册所有消息和Handler的对应关系
     */
    public MessagePool() {
        try {
            // cs
            registerC(BeginGameRq.EXT_FIELD_NUMBER, 0, BeginGameHandler.class);
            registerC(CreateRoleRq.EXT_FIELD_NUMBER, CreateRoleRs.EXT_FIELD_NUMBER, CreateRoleHanlder.class);
            registerC(GetNamesRq.EXT_FIELD_NUMBER, GetNamesRs.EXT_FIELD_NUMBER, GetNamesHandler.class);
            registerC(RoleLoginRq.EXT_FIELD_NUMBER, RoleLoginRs.EXT_FIELD_NUMBER, RoleLoginHandler.class);
            registerC(GetLordRq.EXT_FIELD_NUMBER, GetLordRs.EXT_FIELD_NUMBER, GetLordHandler.class);
            registerC(GetTimeRq.EXT_FIELD_NUMBER, GetTimeRs.EXT_FIELD_NUMBER, GetTimeHandler.class);
            registerC(GetTankRq.EXT_FIELD_NUMBER, GetTankRs.EXT_FIELD_NUMBER, GetTankHandler.class);
            registerC(GetArmyRq.EXT_FIELD_NUMBER, GetArmyRs.EXT_FIELD_NUMBER, GetArmyHandler.class);
            registerC(GetFormRq.EXT_FIELD_NUMBER, GetFormRs.EXT_FIELD_NUMBER, GetFormHandler.class);
            registerC(SetFormRq.EXT_FIELD_NUMBER, SetFormRs.EXT_FIELD_NUMBER, SetFormHandler.class);
            registerC(RepairRq.EXT_FIELD_NUMBER, RepairRs.EXT_FIELD_NUMBER, RepairHandler.class);
            registerC(GetResourceRq.EXT_FIELD_NUMBER, GetResourceRs.EXT_FIELD_NUMBER, GetResourceHandler.class);
            registerC(GetBuildingRq.EXT_FIELD_NUMBER, GetBuildingRs.EXT_FIELD_NUMBER, GetBuildingHandler.class);
            registerC(UpBuildingRq.EXT_FIELD_NUMBER, UpBuildingRs.EXT_FIELD_NUMBER, UpBuildingHandler.class);
            registerC(LoadDataRq.EXT_FIELD_NUMBER, LoadDataRs.EXT_FIELD_NUMBER, LoadDataHandler.class);
            registerC(BuildTankRq.EXT_FIELD_NUMBER, BuildTankRs.EXT_FIELD_NUMBER, BuildTankHandler.class);
            registerC(HeartRq.EXT_FIELD_NUMBER, HeartRs.EXT_FIELD_NUMBER, HeartHandler.class);
            registerC(CancelQueRq.EXT_FIELD_NUMBER, CancelQueRs.EXT_FIELD_NUMBER, CancelQueHandler.class);
            registerC(GetPropRq.EXT_FIELD_NUMBER, GetPropRs.EXT_FIELD_NUMBER, GetPropHandler.class);
            registerC(BuyPropRq.EXT_FIELD_NUMBER, BuyPropRs.EXT_FIELD_NUMBER, BuyPropHandler.class);
            registerC(UsePropRq.EXT_FIELD_NUMBER, UsePropRs.EXT_FIELD_NUMBER, UsePropHandler.class);
            registerC(SpeedQueRq.EXT_FIELD_NUMBER, SpeedQueRs.EXT_FIELD_NUMBER, SpeedQueHandler.class);
            registerC(BuildPropRq.EXT_FIELD_NUMBER, BuildPropRs.EXT_FIELD_NUMBER, BuildPropHandler.class);
            registerC(RefitTankRq.EXT_FIELD_NUMBER, RefitTankRs.EXT_FIELD_NUMBER, RefitTankHandler.class);
            registerC(GetEquipRq.EXT_FIELD_NUMBER, GetEquipRs.EXT_FIELD_NUMBER, GetEquipHandler.class);
            registerC(SellEquipRq.EXT_FIELD_NUMBER, SellEquipRs.EXT_FIELD_NUMBER, SellEquipHandler.class);
            registerC(UpEquipRq.EXT_FIELD_NUMBER, UpEquipRs.EXT_FIELD_NUMBER, UpEquipHandler.class);
            registerC(OnEquipRq.EXT_FIELD_NUMBER, OnEquipRs.EXT_FIELD_NUMBER, OnEquipHandler.class);
            registerC(UpCapacityRq.EXT_FIELD_NUMBER, UpCapacityRs.EXT_FIELD_NUMBER, UpCapacityHandler.class);
            registerC(AllEquipRq.EXT_FIELD_NUMBER, AllEquipRs.EXT_FIELD_NUMBER, AllEquipHandler.class);
            registerC(GetPartRq.EXT_FIELD_NUMBER, GetPartRs.EXT_FIELD_NUMBER, GetPartHander.class);
            registerC(GetChipRq.EXT_FIELD_NUMBER, GetChipRs.EXT_FIELD_NUMBER, GetChipHandler.class);
            registerC(CombinePartRq.EXT_FIELD_NUMBER, CombinePartRs.EXT_FIELD_NUMBER, CombinePartHandler.class);
            registerC(ExplodePartRq.EXT_FIELD_NUMBER, ExplodePartRs.EXT_FIELD_NUMBER, ExplodePartHandler.class);
            registerC(OnPartRq.EXT_FIELD_NUMBER, OnPartRs.EXT_FIELD_NUMBER, OnPartHandler.class);
            registerC(ExplodeChipRq.EXT_FIELD_NUMBER, ExplodeChipRs.EXT_FIELD_NUMBER, ExplodeChipHandler.class);
            registerC(UpPartRq.EXT_FIELD_NUMBER, UpPartRs.EXT_FIELD_NUMBER, UpPartHandler.class);
            registerC(RefitPartRq.EXT_FIELD_NUMBER, RefitPartRs.EXT_FIELD_NUMBER, RefitPartHandler.class);
            registerC(GetScienceRq.EXT_FIELD_NUMBER, GetScienceRs.EXT_FIELD_NUMBER, GetScienceHandler.class);
            registerC(UpgradeScienceRq.EXT_FIELD_NUMBER, UpgradeScienceRs.EXT_FIELD_NUMBER, UpgradeScienceHandler.class);
            registerC(GetCombatRq.EXT_FIELD_NUMBER, GetCombatRs.EXT_FIELD_NUMBER, GetCombatHandler.class);
            registerC(DoCombatRq.EXT_FIELD_NUMBER, DoCombatRs.EXT_FIELD_NUMBER, DoCombatHandler.class);
            registerC(GetMyHerosRq.EXT_FIELD_NUMBER, GetMyHerosRs.EXT_FIELD_NUMBER, GetMyHerosHandler.class);
            registerC(HeroDecomposeRq.EXT_FIELD_NUMBER, HeroDecomposeRs.EXT_FIELD_NUMBER, HeroDecomposeHandler.class);
            registerC(HeroLevelUpRq.EXT_FIELD_NUMBER, HeroLevelUpRs.EXT_FIELD_NUMBER, HeroLevelUpHandler.class);
            registerC(HeroImproveRq.EXT_FIELD_NUMBER, HeroImproveRs.EXT_FIELD_NUMBER, HeroImproveHandler.class);
            registerC(LotteryHeroRq.EXT_FIELD_NUMBER, LotteryHeroRs.EXT_FIELD_NUMBER, LotteryHeroHandler.class);
            registerC(BuyExploreRq.EXT_FIELD_NUMBER, BuyExploreRs.EXT_FIELD_NUMBER, BuyExploreHandler.class);
            registerC(ResetExtrEprRq.EXT_FIELD_NUMBER, ResetExtrEprRs.EXT_FIELD_NUMBER, ResetExtrEprHandler.class);
            registerC(CombatBoxRq.EXT_FIELD_NUMBER, CombatBoxRs.EXT_FIELD_NUMBER, CombatBoxHandler.class);
            registerC(BuyPowerRq.EXT_FIELD_NUMBER, BuyPowerRs.EXT_FIELD_NUMBER, BuyPowerHandler.class);
            registerC(UpRankRq.EXT_FIELD_NUMBER, UpRankRs.EXT_FIELD_NUMBER, UpRankHandler.class);
            registerC(UpCommandRq.EXT_FIELD_NUMBER, UpCommandRs.EXT_FIELD_NUMBER, UpCommandHandler.class);
            registerC(BuyProsRq.EXT_FIELD_NUMBER, BuyProsRs.EXT_FIELD_NUMBER, BuyProsHandler.class);
            registerC(BuyFameRq.EXT_FIELD_NUMBER, BuyFameRs.EXT_FIELD_NUMBER, BuyFameHandler.class);
            registerC(ClickFameRq.EXT_FIELD_NUMBER, ClickFameRs.EXT_FIELD_NUMBER, ClickFameHandler.class);
            registerC(GetFriendRq.EXT_FIELD_NUMBER, GetFriendRs.EXT_FIELD_NUMBER, GetFriendHandler.class);
            registerC(AddFriendRq.EXT_FIELD_NUMBER, AddFriendRs.EXT_FIELD_NUMBER, AddFriendHandler.class);
            registerC(DelFriendRq.EXT_FIELD_NUMBER, DelFriendRs.EXT_FIELD_NUMBER, DelFriendHandler.class);
            registerC(BlessFriendRq.EXT_FIELD_NUMBER, BlessFriendRs.EXT_FIELD_NUMBER, BlessFriendHandler.class);
            registerC(GetBlessRq.EXT_FIELD_NUMBER, GetBlessRs.EXT_FIELD_NUMBER, GetBlessHandler.class);
            registerC(AcceptBlessRq.EXT_FIELD_NUMBER, AcceptBlessRs.EXT_FIELD_NUMBER, AcceptBlessHandler.class);
            registerC(GetSkillRq.EXT_FIELD_NUMBER, GetSkillRs.EXT_FIELD_NUMBER, GetSkillHandler.class);
            registerC(UpSkillRq.EXT_FIELD_NUMBER, UpSkillRs.EXT_FIELD_NUMBER, UpSkillHandler.class);
            registerC(ResetSkillRq.EXT_FIELD_NUMBER, ResetSkillRs.EXT_FIELD_NUMBER, ResetSkillHandler.class);
            // registerC(GetMillRq.EXT_FIELD_NUMBER, GetMillRs.EXT_FIELD_NUMBER,
            // GetMillHandler.class);
            registerC(DestroyMillRq.EXT_FIELD_NUMBER, DestroyMillRs.EXT_FIELD_NUMBER, DestroyMillHandler.class);
            registerC(SeachPlayerRq.EXT_FIELD_NUMBER, SeachPlayerRs.EXT_FIELD_NUMBER, SeachPlayerHandler.class);
            registerC(GetStoreRq.EXT_FIELD_NUMBER, GetStoreRs.EXT_FIELD_NUMBER, GetStoreHandler.class);
            registerC(RecordStoreRq.EXT_FIELD_NUMBER, RecordStoreRs.EXT_FIELD_NUMBER, RecordStoreHandler.class);
            registerC(MarkStoreRq.EXT_FIELD_NUMBER, MarkStoreRs.EXT_FIELD_NUMBER, MarkStoreHandler.class);
            registerC(GetEffectRq.EXT_FIELD_NUMBER, GetEffectRs.EXT_FIELD_NUMBER, GetEffectHandler.class);
            registerC(DoSomeRq.EXT_FIELD_NUMBER, DoSomeRs.EXT_FIELD_NUMBER, DoSomeHandler.class);
            registerC(DelStoreRq.EXT_FIELD_NUMBER, DelStoreRs.EXT_FIELD_NUMBER, DelStoreHandler.class);
            registerC(GetMailRq.EXT_FIELD_NUMBER, GetMailRs.EXT_FIELD_NUMBER, GetMailHandler.class);
            registerC(SendMailRq.EXT_FIELD_NUMBER, SendMailRs.EXT_FIELD_NUMBER, SendMailHandler.class);
            registerC(RewardMailRq.EXT_FIELD_NUMBER, RewardMailRs.EXT_FIELD_NUMBER, RewardMailHandler.class);
            registerC(DelMailRq.EXT_FIELD_NUMBER, DelMailRs.EXT_FIELD_NUMBER, DelMailHandler.class);
            registerC(CollectionsMailRq.EXT_FIELD_NUMBER, CollectionsMailRs.EXT_FIELD_NUMBER, CollectionsMailRqlHandler.class);

            registerC(RewardAllMailRq.EXT_FIELD_NUMBER, RewardAllMailRs.EXT_FIELD_NUMBER, RewardAllMailHandler.class);

            // registerC(ReadMailRq.EXT_FIELD_NUMBER,
            // ReadMailRs.EXT_FIELD_NUMBER, ReadMailHandler.class);
            registerC(GetArenaRq.EXT_FIELD_NUMBER, GetArenaRs.EXT_FIELD_NUMBER, GetArenaHandler.class);
            registerC(DoArenaRq.EXT_FIELD_NUMBER, DoArenaRs.EXT_FIELD_NUMBER, DoArenaHandler.class);
            registerC(BuyArenaRq.EXT_FIELD_NUMBER, BuyArenaRs.EXT_FIELD_NUMBER, BuyArenaHandler.class);
            registerC(ArenaAwardRq.EXT_FIELD_NUMBER, ArenaAwardRs.EXT_FIELD_NUMBER, ArenaAwardHandler.class);
            registerC(UseScoreRq.EXT_FIELD_NUMBER, UseScoreRs.EXT_FIELD_NUMBER, UseScoreHandler.class);
            registerC(InitArenaRq.EXT_FIELD_NUMBER, InitArenaRs.EXT_FIELD_NUMBER, InitArenaHandler.class);
            registerC(DoLotteryRq.EXT_FIELD_NUMBER, DoLotteryRs.EXT_FIELD_NUMBER, DoLotteryHandler.class);
            registerC(GetLotteryEquipRq.EXT_FIELD_NUMBER, GetLotteryEquipRs.EXT_FIELD_NUMBER, GetLotteryEquipHandler.class);
            registerC(GetPartyRankRq.EXT_FIELD_NUMBER, GetPartyRankRs.EXT_FIELD_NUMBER, GetPartyRankHandler.class);
            registerC(GetPartyRq.EXT_FIELD_NUMBER, GetPartyRs.EXT_FIELD_NUMBER, GetPartyHandler.class);
            // registerC(GetPartyBuildingRq.EXT_FIELD_NUMBER,
            // GetPartyBuildingRs.EXT_FIELD_NUMBER,
            // GetPartyBuildingHandler.class);
            registerC(GetPartyMemberRq.EXT_FIELD_NUMBER, GetPartyMemberRs.EXT_FIELD_NUMBER, GetPartyMemberHandler.class);
            registerC(GetPartyHallRq.EXT_FIELD_NUMBER, GetPartyHallRs.EXT_FIELD_NUMBER, GetPartyHallHandler.class);
            registerC(GetPartyScienceRq.EXT_FIELD_NUMBER, GetPartyScienceRs.EXT_FIELD_NUMBER, GetPartyScienceHandler.class);
            registerC(GetPartyWealRq.EXT_FIELD_NUMBER, GetPartyWealRs.EXT_FIELD_NUMBER, GetPartyWealHandler.class);
            registerC(GetPartyShopRq.EXT_FIELD_NUMBER, GetPartyShopRs.EXT_FIELD_NUMBER, GetPartyShopHandler.class);
            registerC(DonatePartyRq.EXT_FIELD_NUMBER, DonatePartyRs.EXT_FIELD_NUMBER, DonatePartyHandler.class);
            registerC(UpPartyBuildingRq.EXT_FIELD_NUMBER, UpPartyBuildingRs.EXT_FIELD_NUMBER, UpPartyBuildingHandler.class);
            registerC(SetPartyJobRq.EXT_FIELD_NUMBER, SetPartyJobRs.EXT_FIELD_NUMBER, SetPartyJobHandler.class);
            registerC(BuyPartyShopRq.EXT_FIELD_NUMBER, BuyPartyShopRs.EXT_FIELD_NUMBER, BuyPartyShopHandler.class);
            registerC(WealDayPartyRq.EXT_FIELD_NUMBER, WealDayPartyRs.EXT_FIELD_NUMBER, WealDayPartyHandler.class);
            registerC(PartyApplyListRq.EXT_FIELD_NUMBER, PartyApplyListRs.EXT_FIELD_NUMBER, PartyApplyListHandler.class);
            registerC(PartyApplyRq.EXT_FIELD_NUMBER, PartyApplyRs.EXT_FIELD_NUMBER, PartyApplyHandler.class);
            registerC(PartyApplyJudgeRq.EXT_FIELD_NUMBER, PartyApplyJudgeRs.EXT_FIELD_NUMBER, PartyApplyJudgeHandler.class);
            registerC(CreatePartyRq.EXT_FIELD_NUMBER, CreatePartyRs.EXT_FIELD_NUMBER, CreatePartyHandler.class);
            registerC(QuitPartyRq.EXT_FIELD_NUMBER, QuitPartyRs.EXT_FIELD_NUMBER, QuitPartyHandler.class);
            registerC(DonateScienceRq.EXT_FIELD_NUMBER, DonateScienceRs.EXT_FIELD_NUMBER, DonateScienceHandler.class);
            registerC(SeachPartyRq.EXT_FIELD_NUMBER, SeachPartyRs.EXT_FIELD_NUMBER, SeachPartyHandler.class);
            registerC(CannlyApplyRq.EXT_FIELD_NUMBER, CannlyApplyRs.EXT_FIELD_NUMBER, CannlyApplyHandler.class);
            registerC(ApplyListRq.EXT_FIELD_NUMBER, ApplyListRs.EXT_FIELD_NUMBER, ApplyListHandler.class);
            registerC(DoneGuideRq.EXT_FIELD_NUMBER, DoneGuideRs.EXT_FIELD_NUMBER, DoneGuideHandler.class);
            registerC(GetPartyTrendRq.EXT_FIELD_NUMBER, GetPartyTrendRs.EXT_FIELD_NUMBER, GetPartyTrendHandler.class);
            registerC(SloganPartyRq.EXT_FIELD_NUMBER, SloganPartyRs.EXT_FIELD_NUMBER, SloganPartyHandler.class);
            registerC(UpMemberJobRq.EXT_FIELD_NUMBER, UpMemberJobRs.EXT_FIELD_NUMBER, UpMemberJobHandler.class);
            registerC(CleanMemberRq.EXT_FIELD_NUMBER, CleanMemberRs.EXT_FIELD_NUMBER, CleanMemberHandler.class);
            registerC(ConcedeJobRq.EXT_FIELD_NUMBER, ConcedeJobRs.EXT_FIELD_NUMBER, ConcedeJobHandler.class);
            registerC(SetMemberJobRq.EXT_FIELD_NUMBER, SetMemberJobRs.EXT_FIELD_NUMBER, SetMemberJobHandler.class);
            registerC(PartyJobCountRq.EXT_FIELD_NUMBER, PartyJobCountRs.EXT_FIELD_NUMBER, PartyJobCountHandler.class);
            registerC(PartyApplyEditRq.EXT_FIELD_NUMBER, PartyApplyEditRs.EXT_FIELD_NUMBER, PartyApplyEditHandler.class);
            registerC(GetMapRq.EXT_FIELD_NUMBER, GetMapRs.EXT_FIELD_NUMBER, GetMapHandler.class);
            registerC(ScoutPosRq.EXT_FIELD_NUMBER, ScoutPosRs.EXT_FIELD_NUMBER, ScoutPosHandler.class);
            registerC(AttackPosRq.EXT_FIELD_NUMBER, AttackPosRs.EXT_FIELD_NUMBER, AttackPosHandler.class);
            // registerC(GetPartySectionRq.EXT_FIELD_NUMBER,
            // GetPartySectionRs.EXT_FIELD_NUMBER, GetPartySectionHander.class);
            registerC(GetPartyCombatRq.EXT_FIELD_NUMBER, GetPartyCombatRs.EXT_FIELD_NUMBER, GetPartyCombatHander.class);
            registerC(DoPartyCombatRq.EXT_FIELD_NUMBER, DoPartyCombatRs.EXT_FIELD_NUMBER, DoPartyCombatHander.class);
            registerC(PartyctAwardRq.EXT_FIELD_NUMBER, PartyctAwardRs.EXT_FIELD_NUMBER, PartyctAwardHander.class);
            registerC(MoveHomeRq.EXT_FIELD_NUMBER, MoveHomeRs.EXT_FIELD_NUMBER, MoveHomeHandler.class);
            registerC(RetreatRq.EXT_FIELD_NUMBER, RetreatRs.EXT_FIELD_NUMBER, RetreatHandler.class);
            registerC(GetMailListRq.EXT_FIELD_NUMBER, GetMailListRs.EXT_FIELD_NUMBER, GetMailListHandler.class);
            registerC(GetMailByIdRq.EXT_FIELD_NUMBER, GetMailByIdRs.EXT_FIELD_NUMBER, GetMailByIdHandler.class);
            registerC(GetSignRq.EXT_FIELD_NUMBER, GetSignRs.EXT_FIELD_NUMBER, GetSignHandler.class);
            registerC(SignRq.EXT_FIELD_NUMBER, SignRs.EXT_FIELD_NUMBER, SignHandler.class);
            registerC(GetInvasionRq.EXT_FIELD_NUMBER, GetInvasionRs.EXT_FIELD_NUMBER, GetInvasionHandler.class);
            registerC(GetAidRq.EXT_FIELD_NUMBER, GetAidRs.EXT_FIELD_NUMBER, GetAidHandler.class);
            registerC(SetGuardRq.EXT_FIELD_NUMBER, SetGuardRs.EXT_FIELD_NUMBER, SetGuardHandler.class);
            registerC(GetMajorTaskRq.EXT_FIELD_NUMBER, GetMajorTaskRs.EXT_FIELD_NUMBER, GetMajorTaskHandler.class);
            registerC(TaskAwardRq.EXT_FIELD_NUMBER, TaskAwardRs.EXT_FIELD_NUMBER, TaskAwardHandler.class);
            registerC(GetDayiyTaskRq.EXT_FIELD_NUMBER, GetDayiyTaskRs.EXT_FIELD_NUMBER, GetDayiyTaskHandler.class);
            registerC(GetLiveTaskRq.EXT_FIELD_NUMBER, GetLiveTaskRs.EXT_FIELD_NUMBER, GetLiveTaskHandler.class);
            registerC(AcceptTaskRq.EXT_FIELD_NUMBER, AcceptTaskRs.EXT_FIELD_NUMBER, AcceptTaskHandler.class);
            registerC(AcceptNoTaskRq.EXT_FIELD_NUMBER, AcceptNoTaskRs.EXT_FIELD_NUMBER, AcceptNoTaskHandler.class);
            registerC(TaskLiveAwardRq.EXT_FIELD_NUMBER, TaskLiveAwardRs.EXT_FIELD_NUMBER, TaskLiveAwardHandler.class);
            registerC(TaskDaylyResetRq.EXT_FIELD_NUMBER, TaskDaylyResetRs.EXT_FIELD_NUMBER, TaskDaylyResetHandler.class);
            registerC(RefreshDayiyTaskRq.EXT_FIELD_NUMBER, RefreshDayiyTaskRs.EXT_FIELD_NUMBER, RefreshDayiyTaskHandler.class);
            registerC(GetChatRq.EXT_FIELD_NUMBER, GetChatRs.EXT_FIELD_NUMBER, GetChatHandler.class);
            registerC(DoChatRq.EXT_FIELD_NUMBER, DoChatRs.EXT_FIELD_NUMBER, DoChatHandler.class);
            registerC(SearchOlRq.EXT_FIELD_NUMBER, SearchOlRs.EXT_FIELD_NUMBER, SearchOlHandler.class);
            registerC(GetReportRq.EXT_FIELD_NUMBER, GetReportRs.EXT_FIELD_NUMBER, GetReportHandler.class);
            registerC(ShareReportRq.EXT_FIELD_NUMBER, ShareReportRs.EXT_FIELD_NUMBER, ShareReportHandler.class);
            registerC(GuardPosRq.EXT_FIELD_NUMBER, GuardPosRs.EXT_FIELD_NUMBER, GuardPosHandler.class);
            registerC(RetreatAidRq.EXT_FIELD_NUMBER, RetreatAidRs.EXT_FIELD_NUMBER, RetreatAidHandler.class);
            registerC(GetExtremeRq.EXT_FIELD_NUMBER, GetExtremeRs.EXT_FIELD_NUMBER, GetExtremeHandler.class);
            registerC(ExtremeRecordRq.EXT_FIELD_NUMBER, ExtremeRecordRs.EXT_FIELD_NUMBER, ExtremeRecordHandler.class);
            registerC(SetDataRq.EXT_FIELD_NUMBER, SetDataRs.EXT_FIELD_NUMBER, SetDataHandler.class);
            registerC(PtcFormRq.EXT_FIELD_NUMBER, PtcFormRs.EXT_FIELD_NUMBER, PtcFormHandler.class);
            registerC(BeginWipeRq.EXT_FIELD_NUMBER, BeginWipeRs.EXT_FIELD_NUMBER, BeginWipeHandler.class);
            registerC(EndWipeRq.EXT_FIELD_NUMBER, EndWipeRs.EXT_FIELD_NUMBER, EndWipeHandler.class);
            registerC(GetGuideGiftRq.EXT_FIELD_NUMBER, GetGuideGiftRs.EXT_FIELD_NUMBER, GetGuideGiftHandler.class);
            registerC(GetRankRq.EXT_FIELD_NUMBER, GetRankRs.EXT_FIELD_NUMBER, GetRankHandler.class);
            registerC(GetPartyLiveRankRq.EXT_FIELD_NUMBER, GetPartyLiveRankRs.EXT_FIELD_NUMBER, GetPartyLiveRankHandler.class);
            registerC(SetPortraitRq.EXT_FIELD_NUMBER, SetPortraitRs.EXT_FIELD_NUMBER, SetPortraitHandler.class);
            registerC(GetLotteryExploreRq.EXT_FIELD_NUMBER, GetLotteryExploreRs.EXT_FIELD_NUMBER, GetLotteryExploreHandler.class);
            registerC(PartyRecruitRq.EXT_FIELD_NUMBER, PartyRecruitRs.EXT_FIELD_NUMBER, PartyRecruitHandler.class);
            registerC(BuyBuildRq.EXT_FIELD_NUMBER, BuyBuildRs.EXT_FIELD_NUMBER, BuyBuildHandler.class);
            registerC(GiftCodeRq.EXT_FIELD_NUMBER, 0, GiftCodeHandler.class);
            registerC(GetActivityListRq.EXT_FIELD_NUMBER, GetActivityListRs.EXT_FIELD_NUMBER, GetActivityListHandler.class);
            registerC(GetActivityAwardRq.EXT_FIELD_NUMBER, GetActivityAwardRs.EXT_FIELD_NUMBER, GetActivityAwardHandler.class);
            registerC(ActLevelRq.EXT_FIELD_NUMBER, ActLevelRs.EXT_FIELD_NUMBER, ActLevelHandler.class);
            registerC(ActAttackRq.EXT_FIELD_NUMBER, ActAttackRs.EXT_FIELD_NUMBER, ActAttackHandler.class);
            registerC(ActFightRq.EXT_FIELD_NUMBER, ActFightRs.EXT_FIELD_NUMBER, ActFightHandler.class);
            registerC(ActCombatRq.EXT_FIELD_NUMBER, ActCombatRs.EXT_FIELD_NUMBER, ActCombatHandler.class);
            registerC(ActHonourRq.EXT_FIELD_NUMBER, ActHonourRs.EXT_FIELD_NUMBER, ActHonourHandler.class);
            registerC(ActPartyLvRq.EXT_FIELD_NUMBER, ActPartyLvRs.EXT_FIELD_NUMBER, ActPartyLvHandler.class);
            registerC(ActPartyDonateRq.EXT_FIELD_NUMBER, ActPartyDonateRs.EXT_FIELD_NUMBER, ActPartyDonateHandler.class);
            registerC(ActCollectRq.EXT_FIELD_NUMBER, ActCollectRs.EXT_FIELD_NUMBER, ActCollectHandler.class);
            registerC(ActCombatSkillRq.EXT_FIELD_NUMBER, ActCombatSkillRs.EXT_FIELD_NUMBER, ActCombatSkillHandler.class);
            registerC(ActPartyFightRq.EXT_FIELD_NUMBER, ActPartyFightRs.EXT_FIELD_NUMBER, ActPartyFightHandler.class);
            registerC(GetActionCenterRq.EXT_FIELD_NUMBER, GetActionCenterRs.EXT_FIELD_NUMBER, GetActionCenterHandler.class);
            registerC(GetActMechaRq.EXT_FIELD_NUMBER, GetActMechaRs.EXT_FIELD_NUMBER, GetActMechaHandler.class);
            registerC(DoActMechaRq.EXT_FIELD_NUMBER, DoActMechaRs.EXT_FIELD_NUMBER, DoActMechaHandler.class);
            registerC(AssembleMechaRq.EXT_FIELD_NUMBER, AssembleMechaRs.EXT_FIELD_NUMBER, AssembleMechaHandler.class);
            registerC(OlAwardRq.EXT_FIELD_NUMBER, OlAwardRs.EXT_FIELD_NUMBER, OlAwardHandler.class);
            registerC(ActInvestRq.EXT_FIELD_NUMBER, ActInvestRs.EXT_FIELD_NUMBER, ActInvestHandler.class);
            registerC(DoInvestRq.EXT_FIELD_NUMBER, DoInvestRs.EXT_FIELD_NUMBER, DoInvestHandler.class);
            registerC(ActPayRedGiftRq.EXT_FIELD_NUMBER, ActPayRedGiftRs.EXT_FIELD_NUMBER, ActPayRedGiftHandler.class);
            registerC(ActEveryDayPayRq.EXT_FIELD_NUMBER, ActEveryDayPayRs.EXT_FIELD_NUMBER, ActEveryDayPayHandler.class);
            registerC(ActPayFirstRq.EXT_FIELD_NUMBER, ActPayFirstRs.EXT_FIELD_NUMBER, ActPayFirstHandler.class);
            registerC(ActQuotaRq.EXT_FIELD_NUMBER, ActQuotaRs.EXT_FIELD_NUMBER, ActQuotaHandler.class);
            registerC(DoQuotaRq.EXT_FIELD_NUMBER, DoQuotaRs.EXT_FIELD_NUMBER, DoQuotaHandler.class);
            registerC(ActPurpleEqpCollRq.EXT_FIELD_NUMBER, ActPurpleEqpCollRs.EXT_FIELD_NUMBER, ActPurpleEqpCollHandler.class);
            registerC(ActPurpleEqpUpRq.EXT_FIELD_NUMBER, ActPurpleEqpUpRs.EXT_FIELD_NUMBER, ActPurpleEqpUpHandler.class);
            registerC(ActCrazyArenaRq.EXT_FIELD_NUMBER, ActCrazyArenaRs.EXT_FIELD_NUMBER, ActCrazyArenaHandler.class);
            registerC(ActCrazyUpgradeRq.EXT_FIELD_NUMBER, ActCrazyUpgradeRs.EXT_FIELD_NUMBER, ActCrazyUpgradeHandler.class);
            registerC(ActPartEvolveRq.EXT_FIELD_NUMBER, ActPartEvolveRs.EXT_FIELD_NUMBER, ActPartEvolveHandler.class);
            registerC(ActCrazyArenaRq.EXT_FIELD_NUMBER, ActCrazyArenaRs.EXT_FIELD_NUMBER, ActCrazyArenaHandler.class);
            registerC(ActFlashSaleRq.EXT_FIELD_NUMBER, ActFlashSaleRs.EXT_FIELD_NUMBER, ActFlashSaleHandler.class);
            registerC(ActContuPayRq.EXT_FIELD_NUMBER, ActContuPayRs.EXT_FIELD_NUMBER, ActContuPayHandler.class);
            registerC(ActFlashMetaRq.EXT_FIELD_NUMBER, ActFlashMetaRs.EXT_FIELD_NUMBER, ActFlashMetaHandler.class);
            registerC(ActTechInfoRq.EXT_FIELD_NUMBER, ActTechInfoRs.EXT_FIELD_NUMBER, ActTechInfoHandler.class);
            registerC(ActDayPayRq.EXT_FIELD_NUMBER, ActDayPayRs.EXT_FIELD_NUMBER, ActDayPayHandler.class);
            registerC(ActDayBuyRq.EXT_FIELD_NUMBER, ActDayBuyRs.EXT_FIELD_NUMBER, ActDayBuyHandler.class);
            registerC(GetPartyLvRankRq.EXT_FIELD_NUMBER, GetPartyLvRankRs.EXT_FIELD_NUMBER, GetPartyLvRankHandler.class);
            registerC(GetActAmyRebateRq.EXT_FIELD_NUMBER, GetActAmyRebateRs.EXT_FIELD_NUMBER, GetActAmyRebateHandler.class);
            registerC(DoActAmyRebateRq.EXT_FIELD_NUMBER, DoActAmyRebateRs.EXT_FIELD_NUMBER, DoActAmyRebateHandler.class);
            registerC(GetActAmyfestivityRq.EXT_FIELD_NUMBER, GetActAmyfestivityRs.EXT_FIELD_NUMBER, GetActAmyfestivityHandler.class);
            registerC(DoActAmyfestivityRq.EXT_FIELD_NUMBER, DoActAmyfestivityRs.EXT_FIELD_NUMBER, DoActAmyfestivityHandler.class);
            registerC(GetActFortuneRq.EXT_FIELD_NUMBER, GetActFortuneRs.EXT_FIELD_NUMBER, GetActFortuneHandler.class);
            registerC(GetActFortuneRankRq.EXT_FIELD_NUMBER, GetActFortuneRankRs.EXT_FIELD_NUMBER, GetActFortuneRankHandler.class);
            registerC(DoActFortuneRq.EXT_FIELD_NUMBER, DoActFortuneRs.EXT_FIELD_NUMBER, DoActFortuneHandler.class);
            registerC(GetRankAwardRq.EXT_FIELD_NUMBER, GetRankAwardRs.EXT_FIELD_NUMBER, GetRankAwardHandler.class);
            registerC(ActMonthSaleRq.EXT_FIELD_NUMBER, ActMonthSaleRs.EXT_FIELD_NUMBER, ActMonthSaleHandler.class);
            registerC(ActGiftOLRq.EXT_FIELD_NUMBER, ActGiftOLRs.EXT_FIELD_NUMBER, ActGiftOLHandler.class);
            registerC(ActMonthLoginRq.EXT_FIELD_NUMBER, ActMonthLoginRs.EXT_FIELD_NUMBER, ActMonthLoginHandler.class);
            registerC(GetActBeeRq.EXT_FIELD_NUMBER, GetActBeeRs.EXT_FIELD_NUMBER, GetActBeeHandler.class);
            registerC(GetActBeeRankRq.EXT_FIELD_NUMBER, GetActBeeRankRs.EXT_FIELD_NUMBER, GetActBeeRankHandler.class);
            registerC(GetRankAwardListRq.EXT_FIELD_NUMBER, GetRankAwardListRs.EXT_FIELD_NUMBER, GetRankAwardListHandler.class);
            registerC(EveLoginRq.EXT_FIELD_NUMBER, EveLoginRs.EXT_FIELD_NUMBER, EveLoginHandler.class);
            registerC(AcceptEveLoginRq.EXT_FIELD_NUMBER, AcceptEveLoginRs.EXT_FIELD_NUMBER, AcceptEveLoginHandler.class);
            registerC(ActEnemySaleRq.EXT_FIELD_NUMBER, ActEnemySaleRs.EXT_FIELD_NUMBER, ActEnemySaleHandler.class);
            registerC(ActUpEquipCritRq.EXT_FIELD_NUMBER, ActUpEquipCritRs.EXT_FIELD_NUMBER, ActUpEquipCritHandler.class);
            registerC(UpEquipStarLvRq.EXT_FIELD_NUMBER, UpEquipStarLvRs.EXT_FIELD_NUMBER, UpEquipStarLvHandler.class);
            registerC(GetActProfotoRq.EXT_FIELD_NUMBER, GetActProfotoRs.EXT_FIELD_NUMBER, GetActProfotoHandler.class);
            registerC(DoActProfotoRq.EXT_FIELD_NUMBER, DoActProfotoRs.EXT_FIELD_NUMBER, DoActProfotoHandler.class);
            registerC(UnfoldProfotoRq.EXT_FIELD_NUMBER, UnfoldProfotoRs.EXT_FIELD_NUMBER, UnfoldProfotoHandler.class);
            registerC(GetActPartDialRq.EXT_FIELD_NUMBER, GetActPartDialRs.EXT_FIELD_NUMBER, GetActPartDialHandler.class);
            registerC(GetActPartDialRankRq.EXT_FIELD_NUMBER, GetActPartDialRankRs.EXT_FIELD_NUMBER, GetActPartDialRankHandler.class);
            registerC(DoActPartDialRq.EXT_FIELD_NUMBER, DoActPartDialRs.EXT_FIELD_NUMBER, DoActPartDialHandler.class);
            registerC(DoActTankRaffleRq.EXT_FIELD_NUMBER, DoActTankRaffleRs.EXT_FIELD_NUMBER, DoActTankRaffleHandler.class);
            registerC(GetActTankRaffleRq.EXT_FIELD_NUMBER, GetActTankRaffleRs.EXT_FIELD_NUMBER, GetActTankRaffleHandler.class);
            registerC(GetPartyAmyPropsRq.EXT_FIELD_NUMBER, GetPartyAmyPropsRs.EXT_FIELD_NUMBER, GetPartyAmyPropsHandler.class);
            registerC(SendPartyAmyPropRq.EXT_FIELD_NUMBER, SendPartyAmyPropRs.EXT_FIELD_NUMBER, SendPartyAmyPropHandler.class);
            registerC(UseAmyPropRq.EXT_FIELD_NUMBER, UseAmyPropRs.EXT_FIELD_NUMBER, UseAmyPropHandler.class);

            registerC(WarRegRq.EXT_FIELD_NUMBER, WarRegRs.EXT_FIELD_NUMBER, WarRegHandler.class);
            registerC(WarMembersRq.EXT_FIELD_NUMBER, WarMembersRs.EXT_FIELD_NUMBER, WarMembersHandler.class);
            registerC(WarPartiesRq.EXT_FIELD_NUMBER, WarPartiesRs.EXT_FIELD_NUMBER, WarPartiesHandler.class);

            registerC(WarReportRq.EXT_FIELD_NUMBER, WarReportRs.EXT_FIELD_NUMBER, WarReportHandler.class);
            registerC(WarCancelRq.EXT_FIELD_NUMBER, WarCancelRs.EXT_FIELD_NUMBER, WarCancelHandler.class);
            registerC(WarWinAwardRq.EXT_FIELD_NUMBER, WarWinAwardRs.EXT_FIELD_NUMBER, WarWinAwardHandler.class);

            registerC(WarRankRq.EXT_FIELD_NUMBER, WarRankRs.EXT_FIELD_NUMBER, WarRankHandler.class);
            registerC(WarWinRankRq.EXT_FIELD_NUMBER, WarWinRankRs.EXT_FIELD_NUMBER, WarWinRankHandler.class);
            registerC(GetWarFightRq.EXT_FIELD_NUMBER, GetWarFightRs.EXT_FIELD_NUMBER, GetWarFightHandler.class);
            registerC(ActReFristPayRq.EXT_FIELD_NUMBER, ActReFristPayRs.EXT_FIELD_NUMBER, ActReFristPayHandler.class);
            registerC(ActGiftPayRq.EXT_FIELD_NUMBER, ActGiftPayRs.EXT_FIELD_NUMBER, ActGiftPayHandler.class);
            registerC(ActCostGoldRq.EXT_FIELD_NUMBER, ActCostGoldRs.EXT_FIELD_NUMBER, ActCostGoldHandler.class);
            registerC(GetActDestroyRq.EXT_FIELD_NUMBER, GetActDestroyRs.EXT_FIELD_NUMBER, GetActDestroyHandler.class);
            registerC(GetActDestroyRankRq.EXT_FIELD_NUMBER, GetActDestroyRankRs.EXT_FIELD_NUMBER, GetActDestroyRankHandler.class);
            registerC(GetActTechRq.EXT_FIELD_NUMBER, GetActTechRs.EXT_FIELD_NUMBER, GetActTechHandler.class);
            registerC(DoActTechRq.EXT_FIELD_NUMBER, DoActTechRs.EXT_FIELD_NUMBER, DoActTechHandler.class);
            registerC(GetActGeneralRq.EXT_FIELD_NUMBER, GetActGeneralRs.EXT_FIELD_NUMBER, GetActGeneralHandler.class);
            registerC(DoActGeneralRq.EXT_FIELD_NUMBER, DoActGeneralRs.EXT_FIELD_NUMBER, DoActGeneralHandler.class);
            registerC(GetActGeneralRankRq.EXT_FIELD_NUMBER, GetActGeneralRankRs.EXT_FIELD_NUMBER, GetActGeneralRankHandler.class);
            registerC(DoPartyTipAwardRq.EXT_FIELD_NUMBER, DoPartyTipAwardRs.EXT_FIELD_NUMBER, DoPartyTipAwardHandler.class);
            registerC(ActVipGiftRq.EXT_FIELD_NUMBER, ActVipGiftRs.EXT_FIELD_NUMBER, ActVipGiftHandler.class);
            registerC(ActPayContu4Rq.EXT_FIELD_NUMBER, ActPayContu4Rs.EXT_FIELD_NUMBER, ActPayContu4Handler.class);
            registerC(DoActVipGiftRq.EXT_FIELD_NUMBER, DoActVipGiftRs.EXT_FIELD_NUMBER, DoActVipGiftHandler.class);
            registerC(GetActEDayPayRq.EXT_FIELD_NUMBER, GetActEDayPayRs.EXT_FIELD_NUMBER, GetActEDayPayHandler.class);
            registerC(DoActEDayPayRq.EXT_FIELD_NUMBER, DoActEDayPayRs.EXT_FIELD_NUMBER, DoActEDayPayHandler.class);
            registerC(GetBossRq.EXT_FIELD_NUMBER, GetBossRs.EXT_FIELD_NUMBER, GetBossHandler.class);
            registerC(GetBossHurtRankRq.EXT_FIELD_NUMBER, GetBossHurtRankRs.EXT_FIELD_NUMBER, GetBossHurtRankHandler.class);
            registerC(SetBossAutoFightRq.EXT_FIELD_NUMBER, SetBossAutoFightRs.EXT_FIELD_NUMBER, SetBossAutoFightHandler.class);
            registerC(BlessBossFightRq.EXT_FIELD_NUMBER, BlessBossFightRs.EXT_FIELD_NUMBER, BlessBossFightHandler.class);
            registerC(FightBossRq.EXT_FIELD_NUMBER, FightBossRs.EXT_FIELD_NUMBER, FightBossHandler.class);
            registerC(BuyBossCdRq.EXT_FIELD_NUMBER, BuyBossCdRs.EXT_FIELD_NUMBER, BuyBossCdHandler.class);
            registerC(BossHurtAwardRq.EXT_FIELD_NUMBER, BossHurtAwardRs.EXT_FIELD_NUMBER, BossHurtAwardHandler.class);
            registerC(ComposeSantRq.EXT_FIELD_NUMBER, ComposeSantRs.EXT_FIELD_NUMBER, ComposeSantHandler.class);
            registerC(GetTipFriendsRq.EXT_FIELD_NUMBER, GetTipFriendsRs.EXT_FIELD_NUMBER, GetTipFriendsHandler.class);
            registerC(AddTipFriendsRq.EXT_FIELD_NUMBER, AddTipFriendsRs.EXT_FIELD_NUMBER, AddTipFriendsHandler.class);
            registerC(BuyArenaCdRq.EXT_FIELD_NUMBER, BuyArenaCdRs.EXT_FIELD_NUMBER, BuyArenaCdHandler.class);
            registerC(BuyAutoBuildRq.EXT_FIELD_NUMBER, BuyAutoBuildRs.EXT_FIELD_NUMBER, BuyAutoBuildHandler.class);
            registerC(SetAutoBuildRq.EXT_FIELD_NUMBER, SetAutoBuildRs.EXT_FIELD_NUMBER, SetAutoBuildHandler.class);
            registerC(ActFesSaleRq.EXT_FIELD_NUMBER, ActFesSaleRs.EXT_FIELD_NUMBER, ActFesSaleHandler.class);
            registerC(GetStaffingRq.EXT_FIELD_NUMBER, GetStaffingRs.EXT_FIELD_NUMBER, GetStaffingHandler.class);
            registerC(AtkSeniorMineRq.EXT_FIELD_NUMBER, AtkSeniorMineRs.EXT_FIELD_NUMBER, AtkSeniorMineHandler.class);
            registerC(SctSeniorMineRq.EXT_FIELD_NUMBER, SctSeniorMineRs.EXT_FIELD_NUMBER, SctSeniorMineHandler.class);
            registerC(GetSeniorMapRq.EXT_FIELD_NUMBER, GetSeniorMapRs.EXT_FIELD_NUMBER, GetSeniorMapHandler.class);
            registerC(ScoreRankRq.EXT_FIELD_NUMBER, ScoreRankRs.EXT_FIELD_NUMBER, ScoreRankHandler.class);
            registerC(ScorePartyRankRq.EXT_FIELD_NUMBER, ScorePartyRankRs.EXT_FIELD_NUMBER, ScorePartyRankHandler.class);

            registerC(BuySeniorRq.EXT_FIELD_NUMBER, BuySeniorRs.EXT_FIELD_NUMBER, BuySeniorHandler.class);
            registerC(ScoreAwardRq.EXT_FIELD_NUMBER, ScoreAwardRs.EXT_FIELD_NUMBER, ScoreAwardHandler.class);
            registerC(PartyScoreAwardRq.EXT_FIELD_NUMBER, PartyScoreAwardRs.EXT_FIELD_NUMBER, PartyScoreAwardHandler.class);
            registerC(GetActConsumeDialRq.EXT_FIELD_NUMBER, GetActConsumeDialRs.EXT_FIELD_NUMBER, GetActConsumeDialHandler.class);

            registerC(GetActConsumeDialRq.EXT_FIELD_NUMBER, GetActConsumeDialRs.EXT_FIELD_NUMBER, GetActConsumeDialHandler.class);
            registerC(GetActConsumeDialRankRq.EXT_FIELD_NUMBER, GetActConsumeDialRankRs.EXT_FIELD_NUMBER, GetActConsumeDialRankHandler.class);
            registerC(DoActConsumeDialRq.EXT_FIELD_NUMBER, DoActConsumeDialRs.EXT_FIELD_NUMBER, DoActConsumeDialHandler.class);
            registerC(GetActVacationlandRq.EXT_FIELD_NUMBER, GetActVacationlandRs.EXT_FIELD_NUMBER, GetActVacationlandHandler.class);
            registerC(BuyActVacationlandRq.EXT_FIELD_NUMBER, BuyActVacationlandRs.EXT_FIELD_NUMBER, BuyActVacationlandHandler.class);
            registerC(DoActVacationlandRq.EXT_FIELD_NUMBER, DoActVacationlandRs.EXT_FIELD_NUMBER, DoActVacationlandHandler.class);
            registerC(GetActPartResolveRq.EXT_FIELD_NUMBER, GetActPartResolveRs.EXT_FIELD_NUMBER, GetActPartResolveHandler.class);
            registerC(DoActPartResolveRq.EXT_FIELD_NUMBER, DoActPartResolveRs.EXT_FIELD_NUMBER, DoActPartResolveHandler.class);
            registerC(GetActPartCashRq.EXT_FIELD_NUMBER, GetActPartCashRs.EXT_FIELD_NUMBER, GetActPartCashHandler.class);
            registerC(DoPartCashRq.EXT_FIELD_NUMBER, DoPartCashRs.EXT_FIELD_NUMBER, DoPartCashHandler.class);
            registerC(RefshPartCashRq.EXT_FIELD_NUMBER, RefshPartCashRs.EXT_FIELD_NUMBER, RefshPartCashHandler.class);
            registerC(GetActEquipCashRq.EXT_FIELD_NUMBER, GetActEquipCashRs.EXT_FIELD_NUMBER, GetActEquipCashHandler.class);
            registerC(DoEquipCashRq.EXT_FIELD_NUMBER, DoEquipCashRs.EXT_FIELD_NUMBER, DoEquipCashHandler.class);
            registerC(RefshEquipCashRq.EXT_FIELD_NUMBER, RefshEquipCashRs.EXT_FIELD_NUMBER, RefshEquipCashHandler.class);
            registerC(GetActGambleRq.EXT_FIELD_NUMBER, GetActGambleRs.EXT_FIELD_NUMBER, GetActGambleHandler.class);
            registerC(DoActGambleRq.EXT_FIELD_NUMBER, DoActGambleRs.EXT_FIELD_NUMBER, DoActGambleHandler.class);
            registerC(GetActPayTurntableRq.EXT_FIELD_NUMBER, GetActPayTurntableRs.EXT_FIELD_NUMBER, GetActPayTurntableHandler.class);
            registerC(DoActPayTurntableRq.EXT_FIELD_NUMBER, DoActPayTurntableRs.EXT_FIELD_NUMBER, DoActPayTurntableHandler.class);
            registerC(GetActPartyDonateRankRq.EXT_FIELD_NUMBER, GetActPartyDonateRankRs.EXT_FIELD_NUMBER, GetActPartyDonateRankHandler.class);
            registerC(GetPartyRankAwardRq.EXT_FIELD_NUMBER, GetPartyRankAwardRs.EXT_FIELD_NUMBER, GetPartyRankAwardHandler.class);
            registerC(MultiHeroImproveRq.EXT_FIELD_NUMBER, MultiHeroImproveRs.EXT_FIELD_NUMBER, MultiHeroImproveHandler.class);
            registerC(TipGuyRq.EXT_FIELD_NUMBER, TipGuyRs.EXT_FIELD_NUMBER, TipGuyHandler.class);
            registerC(GetMilitaryScienceRq.EXT_FIELD_NUMBER, GetMilitaryScienceRs.EXT_FIELD_NUMBER, GetMilitaryScienceHandler.class);
            registerC(UpMilitaryScienceRq.EXT_FIELD_NUMBER, UpMilitaryScienceRs.EXT_FIELD_NUMBER, UpMilitaryScienceHandler.class);
            registerC(ResetMilitaryScienceRq.EXT_FIELD_NUMBER, ResetMilitaryScienceRs.EXT_FIELD_NUMBER, ResetMilitaryScienceHandler.class);
            registerC(GetMilitaryScienceGridRq.EXT_FIELD_NUMBER, GetMilitaryScienceGridRs.EXT_FIELD_NUMBER, GetMilitaryScienceGridHandler.class);
            registerC(FitMilitaryScienceRq.EXT_FIELD_NUMBER, FitMilitaryScienceRs.EXT_FIELD_NUMBER, FitMilitaryScienceHandler.class);
            registerC(MilitaryRefitTankRq.EXT_FIELD_NUMBER, MilitaryRefitTankRs.EXT_FIELD_NUMBER, MilitaryRefitTankHandler.class);
            registerC(GetMilitaryMaterialRq.EXT_FIELD_NUMBER, GetMilitaryMaterialRs.EXT_FIELD_NUMBER, GetMilitaryMaterialHandler.class);
            registerC(UnLockMilitaryGridRq.EXT_FIELD_NUMBER, UnLockMilitaryGridRs.EXT_FIELD_NUMBER, UnLockMilitaryGridHandler.class);
            registerC(LockPartRq.EXT_FIELD_NUMBER, LockPartRs.EXT_FIELD_NUMBER, LockPartHandler.class);
            registerC(PartQualityUpRq.EXT_FIELD_NUMBER, PartQualityUpRs.EXT_FIELD_NUMBER, PartQualityUpHandler.class);
            registerC(GetActNewRaffleRq.EXT_FIELD_NUMBER, GetActNewRaffleRs.EXT_FIELD_NUMBER, GetActNewRaffleHandler.class);
            registerC(DoActNewRaffleRq.EXT_FIELD_NUMBER, DoActNewRaffleRs.EXT_FIELD_NUMBER, DoActNewRaffleHandler.class);
            registerC(LockNewRaffleRq.EXT_FIELD_NUMBER, LockNewRaffleRs.EXT_FIELD_NUMBER, LockNewRaffleHandler.class);

            registerC(GetFortressBattlePartyRq.EXT_FIELD_NUMBER, GetFortressBattlePartyRs.EXT_FIELD_NUMBER, GetFortressBattlePartyHandler.class);
            registerC(SetFortressBattleFormRq.EXT_FIELD_NUMBER, SetFortressBattleFormRs.EXT_FIELD_NUMBER, SetFortressBattleFormHandler.class);
            registerC(GetFortressBattleDefendRq.EXT_FIELD_NUMBER, GetFortressBattleDefendRs.EXT_FIELD_NUMBER, GetFortressBattleDefendHandler.class);
            registerC(AttackFortressRq.EXT_FIELD_NUMBER, AttackFortressRs.EXT_FIELD_NUMBER, AttackFortressHandler.class);
            registerC(BuyFortressBattleCdRq.EXT_FIELD_NUMBER, BuyFortressBattleCdRs.EXT_FIELD_NUMBER, BuyFortressBattleCdHandler.class);
            registerC(FortressBattleRecordRq.EXT_FIELD_NUMBER, FortressBattleRecordRs.EXT_FIELD_NUMBER, FortressBattleRecordHandler.class);
            registerC(GetFortressPartyRankRq.EXT_FIELD_NUMBER, GetFortressPartyRankRs.EXT_FIELD_NUMBER, GetFortressPartyRankHandler.class);
            registerC(GetFortressJiFenRankRq.EXT_FIELD_NUMBER, GetFortressJiFenRankRs.EXT_FIELD_NUMBER, GetFortressJiFenRankHandler.class);
            registerC(GetFortressCombatStaticsRq.EXT_FIELD_NUMBER, GetFortressCombatStaticsRs.EXT_FIELD_NUMBER,
                    GetFortressCombatStaticsHandler.class);
            registerC(GetFortressFightReportRq.EXT_FIELD_NUMBER, GetFortressFightReportRs.EXT_FIELD_NUMBER, GetFortressFightReportHandler.class);
            registerC(GetFortressAttrRq.EXT_FIELD_NUMBER, GetFortressAttrRs.EXT_FIELD_NUMBER, GetFortressAttrHandler.class);
            registerC(UpFortressAttrRq.EXT_FIELD_NUMBER, UpFortressAttrRs.EXT_FIELD_NUMBER, UpFortressAttrHandler.class);
            registerC(GetFortressJobRq.EXT_FIELD_NUMBER, GetFortressJobRs.EXT_FIELD_NUMBER, GetFortressJobHandler.class);
            registerC(FortressAppointRq.EXT_FIELD_NUMBER, FortressAppointRs.EXT_FIELD_NUMBER, FortressAppointHandler.class);
            registerC(GetFortressWinPartyRq.EXT_FIELD_NUMBER, GetFortressWinPartyRs.EXT_FIELD_NUMBER, GetFortressWinPartyHandler.class);
            registerC(GetMyFortressJobRq.EXT_FIELD_NUMBER, GetMyFortressJobRs.EXT_FIELD_NUMBER, GetMyFortressJobHandler.class);
            registerC(GetThisWeekMyWarJiFenRankRq.EXT_FIELD_NUMBER, GetThisWeekMyWarJiFenRankRs.EXT_FIELD_NUMBER,
                    GetThisWeekMyWarJiFenRankHandler.class);

            registerC(GetPendantRq.EXT_FIELD_NUMBER, GetPendantRs.EXT_FIELD_NUMBER, GetPendantHandler.class);
            registerC(GetScoutRq.EXT_FIELD_NUMBER, GetScoutRs.EXT_FIELD_NUMBER, GetScoutHandler.class);

            registerC(GetCrossServerListRq.EXT_FIELD_NUMBER, GetCrossServerListRs.EXT_FIELD_NUMBER, GetCrossServerListHandler.class);
            registerC(GetCrossFightStateRq.EXT_FIELD_NUMBER, GetCrossFightStateRs.EXT_FIELD_NUMBER, GetCrossFightStateHandler.class);
            registerC(CrossFightRegRq.EXT_FIELD_NUMBER, CrossFightRegRs.EXT_FIELD_NUMBER, CrossFightRegHandler.class);
            registerC(GetCrossRegInfoRq.EXT_FIELD_NUMBER, GetCrossRegInfoRs.EXT_FIELD_NUMBER, GetCrossRegInfoHandler.class);
            registerC(CancelCrossRegRq.EXT_FIELD_NUMBER, CancelCrossRegRs.EXT_FIELD_NUMBER, CancelCrossRegHandler.class);
            registerC(GetCrossFormRq.EXT_FIELD_NUMBER, GetCrossFormRs.EXT_FIELD_NUMBER, GetCrossFormHandler.class);
            registerC(SetCrossFormRq.EXT_FIELD_NUMBER, SetCrossFormRs.EXT_FIELD_NUMBER, SetCrossFormHandler.class);
            registerC(GetCrossPersonSituationRq.EXT_FIELD_NUMBER, GetCrossPersonSituationRs.EXT_FIELD_NUMBER, GetCrossPersonSituationHandler.class);
            registerC(GetCrossJiFenRankRq.EXT_FIELD_NUMBER, GetCrossJiFenRankRs.EXT_FIELD_NUMBER, GetCrossJiFenRankHandler.class);
            registerC(GetCrossReportRq.EXT_FIELD_NUMBER, GetCrossReportRs.EXT_FIELD_NUMBER, GetCrossReportHandler.class);
            registerC(GetCrossKnockCompetInfoRq.EXT_FIELD_NUMBER, GetCrossKnockCompetInfoRs.EXT_FIELD_NUMBER, GetCrossKnockCompetInfoHandler.class);
            registerC(GetCrossFinalCompetInfoRq.EXT_FIELD_NUMBER, GetCrossFinalCompetInfoRs.EXT_FIELD_NUMBER, GetCrossFinalCompetInfoHandler.class);
            registerC(GetMyBetRq.EXT_FIELD_NUMBER, GetMyBetRs.EXT_FIELD_NUMBER, GetMyBetHandler.class);
            registerC(BetBattleRq.EXT_FIELD_NUMBER, BetBattleRs.EXT_FIELD_NUMBER, BetBattleHandler.class);
            registerC(ReceiveBetRq.EXT_FIELD_NUMBER, ReceiveBetRs.EXT_FIELD_NUMBER, ReceiveBetHandler.class);
            registerC(GetCrossShopRq.EXT_FIELD_NUMBER, GetCrossShopRs.EXT_FIELD_NUMBER, GetCrossShopHandler.class);
            registerC(ExchangeCrossShopRq.EXT_FIELD_NUMBER, ExchangeCrossShopRs.EXT_FIELD_NUMBER, ExchangeCrossShopHandler.class);
            registerC(GetCrossTrendRq.EXT_FIELD_NUMBER, GetCrossTrendRs.EXT_FIELD_NUMBER, GetCrossTrendHandler.class);
            registerC(GetCrossFinalRankRq.EXT_FIELD_NUMBER, GetCrossFinalRankRs.EXT_FIELD_NUMBER, GetCrossFinalRankHandler.class);
            registerC(ReceiveRankRwardRq.EXT_FIELD_NUMBER, ReceiveRankRwardRs.EXT_FIELD_NUMBER, ReceiveRankRwardHanlder.class);
            registerC(GetCrossRankRq.EXT_FIELD_NUMBER, GetCrossRankRs.EXT_FIELD_NUMBER, GetCrossRankHandler.class);

            // 能晶系统、军团祭坛、祭坛BOSS
            registerC(GetRoleEnergyStoneRq.EXT_FIELD_NUMBER, GetRoleEnergyStoneRs.EXT_FIELD_NUMBER, GetRoleEnergyStoneHandler.class);
            registerC(GetEnergyStoneInlayRq.EXT_FIELD_NUMBER, GetEnergyStoneInlayRs.EXT_FIELD_NUMBER, GetEnergyStoneInlayHandler.class);
            registerC(CombineEnergyStoneRq.EXT_FIELD_NUMBER, CombineEnergyStoneRs.EXT_FIELD_NUMBER, CombineEnergyStoneHandler.class);
            registerC(OnEnergyStoneRq.EXT_FIELD_NUMBER, OnEnergyStoneRs.EXT_FIELD_NUMBER, OnEnergyStoneHandler.class);
            registerC(GetAltarBossDataRq.EXT_FIELD_NUMBER, GetAltarBossDataRs.EXT_FIELD_NUMBER, GetAltarBossDataHandler.class);
            registerC(GetAltarBossHurtRankRq.EXT_FIELD_NUMBER, GetAltarBossHurtRankRs.EXT_FIELD_NUMBER, GetAltarBossHurtRankHandler.class);
            registerC(SetAltarBossAutoFightRq.EXT_FIELD_NUMBER, SetAltarBossAutoFightRs.EXT_FIELD_NUMBER, SetAltarBossAutoFightHandler.class);
            registerC(BlessAltarBossFightRq.EXT_FIELD_NUMBER, BlessAltarBossFightRs.EXT_FIELD_NUMBER, BlessAltarBossFightHandler.class);
            registerC(CallAltarBossRq.EXT_FIELD_NUMBER, CallAltarBossRs.EXT_FIELD_NUMBER, CallAltarBossHandler.class);
            registerC(BuyAltarBossCdRq.EXT_FIELD_NUMBER, BuyAltarBossCdRs.EXT_FIELD_NUMBER, BuyAltarBossCdHandler.class);
            registerC(FightAltarBossRq.EXT_FIELD_NUMBER, FightAltarBossRs.EXT_FIELD_NUMBER, FightAltarBossHandler.class);
            registerC(AltarBossHurtAwardRq.EXT_FIELD_NUMBER, AltarBossHurtAwardRs.EXT_FIELD_NUMBER, AltarBossHurtAwardHandler.class);

            registerC(GetTreasureShopBuyRq.EXT_FIELD_NUMBER, GetTreasureShopBuyRs.EXT_FIELD_NUMBER, GetTreasureShopBuyHandler.class);
            registerC(BuyTreasureShopRq.EXT_FIELD_NUMBER, BuyTreasureShopRs.EXT_FIELD_NUMBER, BuyTreasureShopHandler.class);

            // ios Push评论
            registerC(GetPushStateRq.EXT_FIELD_NUMBER, GetPushStateRs.EXT_FIELD_NUMBER, GetPushStateHandler.class);
            registerC(PushCommentRq.EXT_FIELD_NUMBER, PushCommentRs.EXT_FIELD_NUMBER, PushCommentHandler.class);

            // 军事演习（红蓝大战）
            registerC(GetDrillDataRq.EXT_FIELD_NUMBER, GetDrillDataRs.EXT_FIELD_NUMBER, GetDrillDataHandler.class);
            registerC(DrillEnrollRq.EXT_FIELD_NUMBER, DrillEnrollRs.EXT_FIELD_NUMBER, DrillEnrollHandler.class);
            registerC(ExchangeDrillTankRq.EXT_FIELD_NUMBER, ExchangeDrillTankRs.EXT_FIELD_NUMBER, ExchangeDrillTankHandler.class);
            registerC(GetDrillRecordRq.EXT_FIELD_NUMBER, GetDrillRecordRs.EXT_FIELD_NUMBER, GetDrillRecordHandler.class);
            registerC(GetDrillFightReportRq.EXT_FIELD_NUMBER, GetDrillFightReportRs.EXT_FIELD_NUMBER, GetDrillFightReportHandler.class);
            registerC(GetDrillRankRq.EXT_FIELD_NUMBER, GetDrillRankRs.EXT_FIELD_NUMBER, GetDrillRankHandler.class);
            registerC(DrillRewardRq.EXT_FIELD_NUMBER, DrillRewardRs.EXT_FIELD_NUMBER, DrillRewardHandler.class);
            registerC(GetDrillShopRq.EXT_FIELD_NUMBER, GetDrillShopRs.EXT_FIELD_NUMBER, GetDrillShopHandler.class);
            registerC(ExchangeDrillShopRq.EXT_FIELD_NUMBER, ExchangeDrillShopRs.EXT_FIELD_NUMBER, ExchangeDrillShopHandler.class);
            registerC(GetDrillImproveRq.EXT_FIELD_NUMBER, GetDrillImproveRs.EXT_FIELD_NUMBER, GetDrillImproveHandler.class);
            registerC(DrillImproveRq.EXT_FIELD_NUMBER, DrillImproveRs.EXT_FIELD_NUMBER, DrillImproveHandler.class);
            registerC(GetDrillTankRq.EXT_FIELD_NUMBER, GetDrillTankRs.EXT_FIELD_NUMBER, GetDrillTankHandler.class);

            // 坦克嘉年华活动
            registerC(GetTankCarnivalRq.EXT_FIELD_NUMBER, GetTankCarnivalRs.EXT_FIELD_NUMBER, GetTankCarnivalHandler.class);
            registerC(TankCarnivalRewardRq.EXT_FIELD_NUMBER, TankCarnivalRewardRs.EXT_FIELD_NUMBER, TankCarnivalRewardHandler.class);

            // 叛军入侵
            registerC(GetRebelDataRq.EXT_FIELD_NUMBER, GetRebelDataRs.EXT_FIELD_NUMBER, GetRebelDataHandler.class);
            registerC(GetRebelRankRq.EXT_FIELD_NUMBER, GetRebelRankRs.EXT_FIELD_NUMBER, GetRebelRankHandler.class);
            registerC(RebelRankRewardRq.EXT_FIELD_NUMBER, RebelRankRewardRs.EXT_FIELD_NUMBER, RebelRankRewardHandler.class);
            registerC(RebelIsDeadRq.EXT_FIELD_NUMBER, RebelIsDeadRs.EXT_FIELD_NUMBER, RebelIsDeadHandler.class);

            // 能量补给
            registerC(GetPowerGiveDataRq.EXT_FIELD_NUMBER, GetPowerGiveDataRs.EXT_FIELD_NUMBER, GetPowerGiveDataHandler.class);
            registerC(GetFreePowerRq.EXT_FIELD_NUMBER, GetFreePowerRs.EXT_FIELD_NUMBER, GetFreePowerHandler.class);

            // 配件淬炼
            registerC(SmeltPartRq.EXT_FIELD_NUMBER, SmeltPartRs.EXT_FIELD_NUMBER, SmeltPartHandler.class);
            registerC(SaveSmeltPartRq.EXT_FIELD_NUMBER, SaveSmeltPartRs.EXT_FIELD_NUMBER, SaveSmeltPartHandler.class);
            registerC(TenSmeltPartRq.EXT_FIELD_NUMBER, TenSmeltPartRs.EXT_FIELD_NUMBER, TenSmeltPartHandler.class);

            // 集字活动
            registerC(GetCollectCharacterRq.EXT_FIELD_NUMBER, GetCollectCharacterRs.EXT_FIELD_NUMBER, GetCollectCharacterHadnler.class);
            registerC(CollectCharacterCombineRq.EXT_FIELD_NUMBER, CollectCharacterCombineRs.EXT_FIELD_NUMBER, CollectCharacterCombineHandler.class);
            registerC(CollectCharacterChangeRq.EXT_FIELD_NUMBER, CollectCharacterChangeRs.EXT_FIELD_NUMBER, CollectCharacterChangeHandler.class);

            // m1a2活动
            registerC(GetActM1a2Rq.EXT_FIELD_NUMBER, GetActM1a2Rs.EXT_FIELD_NUMBER, GetActM1a2Handler.class);
            registerC(DoActM1a2Rq.EXT_FIELD_NUMBER, DoActM1a2Rs.EXT_FIELD_NUMBER, DoActM1a2Handler.class);
            registerC(M1a2RefitTankRq.EXT_FIELD_NUMBER, M1a2RefitTankRs.EXT_FIELD_NUMBER, M1a2RefitTankHandler.class);

            // 鲜花祝福活动
            registerC(GetFlowerRq.EXT_FIELD_NUMBER, GetFlowerRs.EXT_FIELD_NUMBER, GetFlowerHandler.class);
            registerC(WishFlowerRq.EXT_FIELD_NUMBER, WishFlowerRs.EXT_FIELD_NUMBER, WishFlowerHandler.class);

            // 跨服军团战
            registerC(GetCrossPartyStateRq.EXT_FIELD_NUMBER, GetCrossPartyStateRs.EXT_FIELD_NUMBER, GetCrossPartyStateHandler.class);
            registerC(GetCrossPartyServerListRq.EXT_FIELD_NUMBER, GetCrossPartyServerListRs.EXT_FIELD_NUMBER, GetCrossPartyServerListHanlder.class);
            registerC(CrossPartyRegRq.EXT_FIELD_NUMBER, CrossPartyRegRs.EXT_FIELD_NUMBER, CrossPartyRegHandler.class);
            registerC(GetCrossPartyMemberRq.EXT_FIELD_NUMBER, GetCrossPartyMemberRs.EXT_FIELD_NUMBER, GetCrossPartyMemberHanlder.class);
            registerC(GetCrossPartyRq.EXT_FIELD_NUMBER, GetCrossPartyRs.EXT_FIELD_NUMBER, GetCrossPartyHandler.class);
            registerC(GetCPFormRq.EXT_FIELD_NUMBER, GetCPFormRs.EXT_FIELD_NUMBER, GetCPFormHandler.class);
            registerC(SetCPFormRq.EXT_FIELD_NUMBER, SetCPFormRs.EXT_FIELD_NUMBER, SetCPFormHandler.class);
            registerC(GetCPSituationRq.EXT_FIELD_NUMBER, GetCPSituationRs.EXT_FIELD_NUMBER, GetCPSituationHandler.class);
            registerC(GetCPOurServerSituationRq.EXT_FIELD_NUMBER, GetCPOurServerSituationRs.EXT_FIELD_NUMBER, GetCPOurServerSituationHandler.class);
            registerC(GetCPReportRq.EXT_FIELD_NUMBER, GetCPReportRs.EXT_FIELD_NUMBER, GetCPReportHanlder.class);
            registerC(GetCPRankRq.EXT_FIELD_NUMBER, GetCPRankRs.EXT_FIELD_NUMBER, GetCPRankHandler.class);
            registerC(ReceiveCPRewardRq.EXT_FIELD_NUMBER, ReceiveCPRewardRs.EXT_FIELD_NUMBER, ReceiveCPRewardHandler.class);
            registerC(GetCPMyRegInfoRq.EXT_FIELD_NUMBER, GetCPMyRegInfoRs.EXT_FIELD_NUMBER, GetCPMyRegInfoHandler.class);
            registerC(GetCPShopRq.EXT_FIELD_NUMBER, GetCPShopRs.EXT_FIELD_NUMBER, GetCPShopHandler.class);
            registerC(ExchangeCPShopRq.EXT_FIELD_NUMBER, ExchangeCPShopRs.EXT_FIELD_NUMBER, ExchangeCPShopHandler.class);
            registerC(GetCPTrendRq.EXT_FIELD_NUMBER, GetCPTrendRs.EXT_FIELD_NUMBER, GetCPTrendHandler.class);

            //新的累计充值（神秘部队）
            registerC(GetNewPayEverydayRq.EXT_FIELD_NUMBER, GetNewPayEverydayRs.EXT_FIELD_NUMBER, GetNewPayEverydayHandler.class);
            //军团充值
            registerC(GetPartyRechargeRq.EXT_FIELD_NUMBER, GetPartyRechargeRs.EXT_FIELD_NUMBER, GetPartyRechargeHandler.class);

            // 能晶一键镶嵌
            registerC(AllEnergyStoneRq.EXT_FIELD_NUMBER, AllEnergyStoneRs.EXT_FIELD_NUMBER, AllEnergyStoneHandler.class);

            // 返利我做主
            registerC(GetPayRebateRq.EXT_FIELD_NUMBER, GetPayRebateRs.EXT_FIELD_NUMBER, GetActPayRebateHandler.class);
            registerC(DoPayRebateRq.EXT_FIELD_NUMBER, DoPayRebateRs.EXT_FIELD_NUMBER, DoActPayRebateHandler.class);

            // 装备进阶
            registerC(EquipQualityUpRq.EXT_FIELD_NUMBER, EquipQualityUpRs.EXT_FIELD_NUMBER, EquipQualityUpHandler.class);

            // 勋章
            registerC(BuyMedalCdTimeRq.EXT_FIELD_NUMBER, BuyMedalCdTimeRs.EXT_FIELD_NUMBER, BuyMedalCdTimeHandler.class);
            registerC(CombineMedalRq.EXT_FIELD_NUMBER, CombineMedalRs.EXT_FIELD_NUMBER, CombineMedalHandler.class);
            registerC(ExplodeMedalChipRq.EXT_FIELD_NUMBER, ExplodeMedalChipRs.EXT_FIELD_NUMBER, ExplodeMedalChipHandler.class);
            registerC(ExplodeMedalRq.EXT_FIELD_NUMBER, ExplodeMedalRs.EXT_FIELD_NUMBER, ExplodeMedalHandler.class);
            registerC(GetMedalChipRq.EXT_FIELD_NUMBER, GetMedalChipRs.EXT_FIELD_NUMBER, GetMedalChipHandler.class);
            registerC(GetMedalRq.EXT_FIELD_NUMBER, GetMedalRs.EXT_FIELD_NUMBER, GetMedalHandler.class);
            registerC(LockMedalRq.EXT_FIELD_NUMBER, LockMedalRs.EXT_FIELD_NUMBER, LockMedalHandler.class);
            registerC(OnMedalRq.EXT_FIELD_NUMBER, OnMedalRs.EXT_FIELD_NUMBER, OnMedalHandler.class);
            registerC(RefitMedalRq.EXT_FIELD_NUMBER, RefitMedalRs.EXT_FIELD_NUMBER, RefitMedalHandler.class);
            registerC(UpMedalRq.EXT_FIELD_NUMBER, UpMedalRs.EXT_FIELD_NUMBER, UpMedalHandler.class);
            registerC(GetMedalBounsRq.EXT_FIELD_NUMBER, GetMedalBounsRs.EXT_FIELD_NUMBER, GetMedalBounsHandler.class);
            registerC(DoMedalBounsRq.EXT_FIELD_NUMBER, DoMedalBounsRs.EXT_FIELD_NUMBER, DoMedalBounsHandler.class);
            registerC(TransMedalRq.EXT_FIELD_NUMBER, TransMedalRs.EXT_FIELD_NUMBER, TransMedalHandler.class);

            // 海贼宝藏
            registerC(GetPirateLotteryRq.EXT_FIELD_NUMBER, GetPirateLotteryRs.EXT_FIELD_NUMBER, GetActPirateLotteryHandler.class);
            registerC(DoPirateLotteryRq.EXT_FIELD_NUMBER, DoPirateLotteryRs.EXT_FIELD_NUMBER, DoActPirateLotteryHandler.class);
            registerC(ResetPirateLotteryRq.EXT_FIELD_NUMBER, ResetPirateLotteryRs.EXT_FIELD_NUMBER, ResetActPirateLotteryHandler.class);
            registerC(GetPirateChangeRq.EXT_FIELD_NUMBER, GetPirateChangeRs.EXT_FIELD_NUMBER, GetActPirateChangeHandler.class);
            registerC(DoPirateChangeRq.EXT_FIELD_NUMBER, DoPirateChangeRs.EXT_FIELD_NUMBER, DoActPirateChangeHandler.class);
            registerC(GetActPirateRankRq.EXT_FIELD_NUMBER, GetActPirateRankRs.EXT_FIELD_NUMBER, GetActPirateRankHandler.class);

            // 机甲贺岁
            registerC(GetActBossRq.EXT_FIELD_NUMBER, GetActBossRs.EXT_FIELD_NUMBER, GetActBossHandler.class);
            registerC(CallActBossRq.EXT_FIELD_NUMBER, CallActBossRs.EXT_FIELD_NUMBER, CallActBossHandler.class);
            registerC(AttackActBossRq.EXT_FIELD_NUMBER, AttackActBossRs.EXT_FIELD_NUMBER, AttackActBossHandler.class);
            registerC(BuyActBossCdRq.EXT_FIELD_NUMBER, BuyActBossCdRs.EXT_FIELD_NUMBER, BuyActBossCdHandler.class);
            registerC(GetActBossRankRq.EXT_FIELD_NUMBER, GetActBossRankRs.EXT_FIELD_NUMBER, GetActBossRankHandler.class);

            // 连续充值（多档位）
            registerC(ActContuPayMoreRq.EXT_FIELD_NUMBER, ActContuPayMoreRs.EXT_FIELD_NUMBER, ActContuPayMoreHandler.class);

            // 能晶转盘
            registerC(GetActEnergyStoneDialRq.EXT_FIELD_NUMBER, GetActEnergyStoneDialRs.EXT_FIELD_NUMBER, GetActEnergyStoneDialHandler.class);
            registerC(GetActEnergyStoneDialRankRq.EXT_FIELD_NUMBER, GetActEnergyStoneDialRankRs.EXT_FIELD_NUMBER, GetActEnergyStoneDialRankHandler.class);
            registerC(DoActEnergyStoneDialRq.EXT_FIELD_NUMBER, DoActEnergyStoneDialRs.EXT_FIELD_NUMBER, DoActEnergyStoneDialHandler.class);

            // 选择性使用道具
            registerC(UsePropChooseRq.EXT_FIELD_NUMBER, UsePropChooseRs.EXT_FIELD_NUMBER, UsePropChooseHandler.class);

            // 狂欢祈福
            registerC(GetActHilarityPrayRq.EXT_FIELD_NUMBER, GetActHilarityPrayRs.EXT_FIELD_NUMBER, GetActHilarityPrayHandler.class);
            registerC(ReceiveActHilarityPrayRq.EXT_FIELD_NUMBER, ReceiveActHilarityPrayRs.EXT_FIELD_NUMBER, RecevieActHilarityPrayHandler.class);
            registerC(GetActHilarityPrayActionRq.EXT_FIELD_NUMBER, GetActHilarityPrayActionRs.EXT_FIELD_NUMBER,
                    GetActHilarityPrayActionHandler.class);
            registerC(DoActHilarityPrayActionRq.EXT_FIELD_NUMBER, DoActHilarityPrayActionRs.EXT_FIELD_NUMBER, DoActHilarityPrayActionHandler.class);
            registerC(ReceiveActHilarityPrayActionRq.EXT_FIELD_NUMBER, ReceiveActHilarityPrayActionRs.EXT_FIELD_NUMBER,
                    RecevieActHilarityPrayActionHandler.class);
            registerC(SpeedActHilarityPrayActionRq.EXT_FIELD_NUMBER, SpeedActHilarityPrayActionRs.EXT_FIELD_NUMBER,
                    SpeedActHilarityPrayActionHandler.class);

            // 光盘计划
            registerC(GetOverRebateActRq.EXT_FIELD_NUMBER, GetOverRebateActRs.EXT_FIELD_NUMBER, GetActOverRebateHandler.class);
            registerC(DoOverRebateActRq.EXT_FIELD_NUMBER, DoOverRebateActRs.EXT_FIELD_NUMBER, DoActOverRebateHandler.class);

            // 拜神许愿
            registerC(GetWorshipGodActRq.EXT_FIELD_NUMBER, GetWorshipGodActRs.EXT_FIELD_NUMBER, GetActWorshipGodHandler.class);
            registerC(DoWorshipGodActRq.EXT_FIELD_NUMBER, DoWorshipGodActRs.EXT_FIELD_NUMBER, DoActWorshipGodHandler.class);
            registerC(GetWorshipTaskActRq.EXT_FIELD_NUMBER, GetWorshipTaskActRs.EXT_FIELD_NUMBER, GetActWorshipTaskHandler.class);
            registerC(DoWorshipTaskActRq.EXT_FIELD_NUMBER, DoWorshipTaskActRs.EXT_FIELD_NUMBER, DoActWorshipTaskHandler.class);

            // 合服奖励
            registerC(GetActMergeGiftRq.EXT_FIELD_NUMBER, GetActMergeGiftRs.EXT_FIELD_NUMBER, ActMergeGiftHandler.class);

            // 奖励锁定
            registerC(LockHeroRq.EXT_FIELD_NUMBER, LockHeroRs.EXT_FIELD_NUMBER, LockHeroHandler.class);

            // 活动叛军
            registerC(ActRebelIsDeadRq.EXT_FIELD_NUMBER, ActRebelIsDeadRs.EXT_FIELD_NUMBER, ActRebelDeadHandler.class);
            registerC(GetActRebelRankRq.EXT_FIELD_NUMBER, GetActRebelRankRs.EXT_FIELD_NUMBER, GetActRebelRankHandler.class);
            registerC(ActRebelRankRewardRq.EXT_FIELD_NUMBER, ActRebelRankRewardRs.EXT_FIELD_NUMBER, ActRebelRankRewardHandler.class);

            // 7日活动
            registerC(GetDay7ActTipsRq.EXT_FIELD_NUMBER, GetDay7ActTipsRs.EXT_FIELD_NUMBER, GetDay7ActTipsHandler.class);
            registerC(GetDay7ActRq.EXT_FIELD_NUMBER, GetDay7ActRs.EXT_FIELD_NUMBER, GetDay7ActHandler.class);
            registerC(RecvDay7ActAwardRq.EXT_FIELD_NUMBER, RecvDay7ActAwardRs.EXT_FIELD_NUMBER, RecvDay7ActAwardHandler.class);
            registerC(Day7ActLvUpRq.EXT_FIELD_NUMBER, Day7ActLvUpRs.EXT_FIELD_NUMBER, Day7ActLvUpHandler.class);

            // 将领觉醒
            registerC(HeroAwakenRq.EXT_FIELD_NUMBER, HeroAwakenRs.EXT_FIELD_NUMBER, HeroAwakenHandler.class);
            registerC(HeroAwakenSkillLvRq.EXT_FIELD_NUMBER, HeroAwakenSkillLvRs.EXT_FIELD_NUMBER, HeroAwakenLvSkillHandler.class);

            // 参谋配置-文官入驻（将领入驻）
            registerC(GetHeroPutInfoRq.EXT_FIELD_NUMBER, GetHeroPutInfoRs.EXT_FIELD_NUMBER, GetHeroPutInfoHandler.class);
            registerC(SetHeroPutRq.EXT_FIELD_NUMBER, SetHeroPutRs.EXT_FIELD_NUMBER, SetHeroPutHandler.class);

            // VIP商城购买
            registerC(GetShopInfoRq.EXT_FIELD_NUMBER, GetShopInfoRs.EXT_FIELD_NUMBER, GetShopInfoHandler.class);
            registerC(BuyShopGoodsRq.EXT_FIELD_NUMBER, BuyShopGoodsRs.EXT_FIELD_NUMBER, BuyShopGoodsHandler.class);

            // 西点学院活动
            registerC(GetActCollegeRq.EXT_FIELD_NUMBER, GetActCollegeRs.EXT_FIELD_NUMBER, GetActCollegeHandler.class);
            registerC(BuyActPropRq.EXT_FIELD_NUMBER, BuyActPropRs.EXT_FIELD_NUMBER, BuyActPropHandler.class);
            registerC(DoActCollegeRq.EXT_FIELD_NUMBER, DoActCollegeRs.EXT_FIELD_NUMBER, DoActCollegeHandler.class);

            // 每月签到
            registerC(GetMonthSignRq.EXT_FIELD_NUMBER, GetMonthSignRs.EXT_FIELD_NUMBER, GetMonthSignHandler.class);
            registerC(MonthSignRq.EXT_FIELD_NUMBER, MonthSignRs.EXT_FIELD_NUMBER, MonthSignHandler.class);
            registerC(DrawMonthSignExtRq.EXT_FIELD_NUMBER, DrawMonthSignExtRs.EXT_FIELD_NUMBER, DrawMonthSignExtHandler.class);

            // 飞艇功能
            registerC(GetAirshipRq.EXT_FIELD_NUMBER, GetAirshipRs.EXT_FIELD_NUMBER, GetAirshipHandler.class);
            registerC(CreateAirshipTeamRq.EXT_FIELD_NUMBER, CreateAirshipTeamRs.EXT_FIELD_NUMBER, CreateAirshipTeamHandler.class);
            registerC(CancelTeamRq.EXT_FIELD_NUMBER, CancelTeamRs.EXT_FIELD_NUMBER, CancelTeamHandler.class);
            registerC(JoinAirshipTeamRq.EXT_FIELD_NUMBER, JoinAirshipTeamRs.EXT_FIELD_NUMBER, JoinAirshipTeamHandler.class);
            registerC(GetAirshipTeamListRq.EXT_FIELD_NUMBER, GetAirshipTeamListRs.EXT_FIELD_NUMBER, GetAirshipTeamListHandler.class);
            registerC(GetAirshipTeamDetailRq.EXT_FIELD_NUMBER, GetAirshipTeamDetailRs.EXT_FIELD_NUMBER, GetAirshipTeamDetailHandler.class);
            registerC(SetPlayerAttackSeqRq.EXT_FIELD_NUMBER, SetPlayerAttackSeqRs.EXT_FIELD_NUMBER, SetPlayerAttackSeqHandler.class);
            registerC(StartAirshipTeamMarchRq.EXT_FIELD_NUMBER, StartAirshipTeamMarchRs.EXT_FIELD_NUMBER, StartAirshipTeamMarchHandler.class);
            registerC(GuardAirshipRq.EXT_FIELD_NUMBER, GuardAirshipRs.EXT_FIELD_NUMBER, GuardAirshipHandler.class);
            registerC(GetAirshpTeamArmyRq.EXT_FIELD_NUMBER, GetAirshpTeamArmyRs.EXT_FIELD_NUMBER, GetAirshpTeamArmy.class);
            registerC(GetAirshipGuardRq.EXT_FIELD_NUMBER, GetAirshipGuardRs.EXT_FIELD_NUMBER, GetAirshipGuardHandler.class);
            registerC(ScoutAirshipRq.EXT_FIELD_NUMBER, ScoutAirshipRs.EXT_FIELD_NUMBER, ScoutAirshipHandler.class);
            registerC(RecvAirshipProduceAwardRq.EXT_FIELD_NUMBER, RecvAirshipProduceAwardRs.EXT_FIELD_NUMBER, RecvAirshipProduceAwardHandler.class);
            registerC(GetPartyAirshipCommanderRq.EXT_FIELD_NUMBER, GetPartyAirshipCommanderRs.EXT_FIELD_NUMBER,
                    GetPartyAirshipCommanderHandler.class);
            registerC(AppointAirshipCommanderRq.EXT_FIELD_NUMBER, AppointAirshipCommanderRs.EXT_FIELD_NUMBER, AppointAirshipCommanderHandler.class);
            registerC(RebuildAirshipRq.EXT_FIELD_NUMBER, RebuildAirshipRs.EXT_FIELD_NUMBER, RebuildAirshipHandler.class);
            registerC(GetAirshipPlayerRq.EXT_FIELD_NUMBER, GetAirshipPlayerRs.EXT_FIELD_NUMBER, GetAirshipPlayerInfoHandler.class);
            registerC(GetAirshipGuardArmyRq.EXT_FIELD_NUMBER, GetAirshipGuardArmyRs.EXT_FIELD_NUMBER, GetAirshipGuardArmyHandler.class);
            registerC(GetRecvAirshipProduceAwardRecordRq.EXT_FIELD_NUMBER, GetRecvAirshipProduceAwardRecordRs.EXT_FIELD_NUMBER,
                    GetRecvAirshipProduceAwardRecordHandler.class);

            // 军备相关
            registerC(GetLordEquipInfoRq.EXT_FIELD_NUMBER, GetLordEquipInfoRs.EXT_FIELD_NUMBER, GetLordEquipHandler.class);
            registerC(PutonLordEquipRq.EXT_FIELD_NUMBER, PutonLordEquipRs.EXT_FIELD_NUMBER, PutonLordEquipHandler.class);
            registerC(TakeOffEquipRq.EXT_FIELD_NUMBER, TakeOffEquipRs.EXT_FIELD_NUMBER, TakeOffLordEquipHandler.class);
            registerC(ResloveLordEquipRq.EXT_FIELD_NUMBER, ResloveLordEquipRs.EXT_FIELD_NUMBER, ResloveLordEquipHandler.class);
            registerC(UseTechnicalRq.EXT_FIELD_NUMBER, UseTechnicalRs.EXT_FIELD_NUMBER, UseTechnicalHandler.class);
            registerC(EmployTechnicalRq.EXT_FIELD_NUMBER, EmployTechnicalRs.EXT_FIELD_NUMBER, EmployTechnicalHandler.class);
            registerC(LordEquipSpeedByGoldRq.EXT_FIELD_NUMBER, LordEquipSpeedByGoldRs.EXT_FIELD_NUMBER, SpeedByGoldHandler.class);
            registerC(ProductEquipRq.EXT_FIELD_NUMBER, ProductEquipRs.EXT_FIELD_NUMBER, ProductEquipHandler.class);
            registerC(CollectLordEquipRq.EXT_FIELD_NUMBER, CollectLordEquipRs.EXT_FIELD_NUMBER, CollectLordEquipHandler.class);
            registerC(ShareLordEquipRq.EXT_FIELD_NUMBER, ShareLordEquipRs.EXT_FIELD_NUMBER, ShareLordEquipHandler.class);
            // 军备方案
            registerC(SetLeqSchemeRq.EXT_FIELD_NUMBER, SetLeqSchemeRs.EXT_FIELD_NUMBER, SetLeqSchemeHandler.class);
            registerC(PutonLeqSchemeRq.EXT_FIELD_NUMBER, PutonLeqSchemeRs.EXT_FIELD_NUMBER, PutonLeqSchemeHandler.class);
            registerC(GetAllLeqSchemeRq.EXT_FIELD_NUMBER, GetAllLeqSchemeRs.EXT_FIELD_NUMBER, GetAllLeqSchemeHandler.class);
            // 军备材料相关
            registerC(ProductLordEquipMatRq.EXT_FIELD_NUMBER, ProductLordEquipMatRs.EXT_FIELD_NUMBER, ProductLordEquipMatHandler.class);
            registerC(BuyMaterialProRq.EXT_FIELD_NUMBER, BuyMaterialProRs.EXT_FIELD_NUMBER, BuyMaterialProHandler.class);
            registerC(CollectLeqMaterialRq.EXT_FIELD_NUMBER, CollectLeqMaterialRs.EXT_FIELD_NUMBER, CollectLembHandler.class);
            registerC(GetLembQueueRq.EXT_FIELD_NUMBER, GetLembQueueRs.EXT_FIELD_NUMBER, GetLembQueueHandler.class);

            // 军备洗炼
            registerC(LordEquipChangeRq.EXT_FIELD_NUMBER, LordEquipChangeRs.EXT_FIELD_NUMBER, ProductLordEquipChangeHandler.class);
            registerC(LockLordEquipRq.EXT_FIELD_NUMBER, LockLordEquipRs.EXT_FIELD_NUMBER, LockLordEquipHandler.class);
            registerC(LordEquipChangeFreeTimeRq.EXT_FIELD_NUMBER, LordEquipChangeFreeTimeRs.EXT_FIELD_NUMBER,
                    GetLordEquipChangFreeTimeeHandler.class);

            // 运营活动相关
            // 部件淬炼活动
            registerC(GetActSmeltPartCritRq.EXT_FIELD_NUMBER, GetActSmeltPartCritRs.EXT_FIELD_NUMBER, GetActSmeltPartCritHandler.class);
            registerC(GetActSmeltPartMasterRq.EXT_FIELD_NUMBER, GetActSmeltPartMasterRs.EXT_FIELD_NUMBER, GetActSmeltPartMasterHandler.class);
            registerC(LotteryInSmeltPartMasterRq.EXT_FIELD_NUMBER, LotteryInSmeltPartMasterRs.EXT_FIELD_NUMBER, GetActSPMLotteryHandler.class);
            registerC(GetActSmeltPartMasterRankRq.EXT_FIELD_NUMBER, GetActSmeltPartMasterRankRs.EXT_FIELD_NUMBER, GetActSPMRankHandler.class);

            // 秘密行动
            registerC(GetActScrtWpnStdCntRq.EXT_FIELD_NUMBER, GetActScrtWpnStdCntRs.EXT_FIELD_NUMBER, GetActScrtWpnStdCntHandler.class);
            // 大咖带队
            registerC(GetActVipCountInfoRq.EXT_FIELD_NUMBER, GetActVipCountInfoRs.EXT_FIELD_NUMBER, GetActVipCountInfoHandler.class);
            // 闪击行动
            registerC(GetActStrokeRq.EXT_FIELD_NUMBER, GetActStrokeRs.EXT_FIELD_NUMBER, GetActStrokeHander.class);
            registerC(DrawActStrokeAwardRq.EXT_FIELD_NUMBER, DrawActStrokeAwardRs.EXT_FIELD_NUMBER, DrawActStrokeAwardHandler.class);
            // 探宝积分活动
            registerC(GetActLotteryExploreRq.EXT_FIELD_NUMBER, GetActLotteryExploreRs.EXT_FIELD_NUMBER, GetActLotteryExploreHandler.class);

            // 广告相关
            registerC(GetLoginADStatusRq.EXT_FIELD_NUMBER, GetLoginADStatusRs.EXT_FIELD_NUMBER, GetLoginADStatusHandler.class);
            registerC(PlayLoginADRq.EXT_FIELD_NUMBER, PlayLoginADRs.EXT_FIELD_NUMBER, PlayLoginADHandler.class);
            registerC(GetFirstGiftADStatusRq.EXT_FIELD_NUMBER, GetFirstGiftADStatusRs.EXT_FIELD_NUMBER, GetFirstGiftADStatusHandler.class);
            registerC(PlayFirstGiftADRq.EXT_FIELD_NUMBER, PlayFirstGiftADRs.EXT_FIELD_NUMBER, PlayFirstGiftADHandler.class);
            registerC(AwardFirstGiftADRq.EXT_FIELD_NUMBER, AwardFirstGiftADRs.EXT_FIELD_NUMBER, AwardFirstGiftADHandler.class);
            registerC(GetExpAddStatusRq.EXT_FIELD_NUMBER, GetExpAddStatusRs.EXT_FIELD_NUMBER, GetExpAddStatusHandler.class);
            registerC(PlayExpAddADRq.EXT_FIELD_NUMBER, PlayExpAddADRs.EXT_FIELD_NUMBER, PlayExpAddADHandler.class);
            registerC(GetDay7ActLvUpADStatusRq.EXT_FIELD_NUMBER, GetDay7ActLvUpADStatusRs.EXT_FIELD_NUMBER, GetDay7ActLvUpADStatusHandler.class);
            registerC(PlayDay7ActLvUpADRq.EXT_FIELD_NUMBER, PlayDay7ActLvUpADRs.EXT_FIELD_NUMBER, PlayDay7ActLvUpADHandler.class);
            registerC(PlayStaffingAddADRq.EXT_FIELD_NUMBER, PlayStaffingAddADRs.EXT_FIELD_NUMBER, PlayStaffingAddADHandler.class);
            registerC(GetStaffingAddStatusRq.EXT_FIELD_NUMBER, GetStaffingAddStatusRs.EXT_FIELD_NUMBER, GetStaffingAddStatusHandler.class);
            registerC(PlayAddPowerADRq.EXT_FIELD_NUMBER, PlayAddPowerADRs.EXT_FIELD_NUMBER, PlayAddPowerADHandler.class);
            registerC(PlayAddCommandADRq.EXT_FIELD_NUMBER, PlayAddCommandADRs.EXT_FIELD_NUMBER, PlayAddCommandADHandler.class);
            registerC(GetAddPowerADRq.EXT_FIELD_NUMBER, GetAddPowerADRs.EXT_FIELD_NUMBER, GetAddPowerADHandler.class);
            registerC(GetAddCommandADRq.EXT_FIELD_NUMBER, GetAddCommandADRs.EXT_FIELD_NUMBER, GetAddCommandADHandler.class);

            // 玩家回归
            registerC(GetPlayerBackMessageRq.EXT_FIELD_NUMBER, GetPlayerBackMessageRs.EXT_FIELD_NUMBER, GetPlayerBackMessageHandler.class);
            registerC(GetPlayerBackAwardsRq.EXT_FIELD_NUMBER, GetPlayerBackAwardsRs.EXT_FIELD_NUMBER, GetPlayerBackAwardsHandler.class);
            registerC(GetPlayerBackBuffRq.EXT_FIELD_NUMBER, GetPlayerBackBuffRs.EXT_FIELD_NUMBER, GetPlayerBackBuffHandler.class);

            // 能量灌注活动
            registerC(GetActCumulativePayInfoRq.EXT_FIELD_NUMBER, GetActCumulativePayInfoRs.EXT_FIELD_NUMBER, GetActCumulativePayInfoHandler.class);
            registerC(GetActCumulativePayAwardRq.EXT_FIELD_NUMBER, GetActCumulativePayAwardRs.EXT_FIELD_NUMBER,
                    GetActCumulativePayAwardHandler.class);
            registerC(ActCumulativeRePayRq.EXT_FIELD_NUMBER, ActCumulativeRePayRs.EXT_FIELD_NUMBER, ActCumulativeRePayHandler.class);

            // 自选豪礼
            registerC(GetActChooseGiftRq.EXT_FIELD_NUMBER, GetActChooseGiftRs.EXT_FIELD_NUMBER, GetActChooseGiftHandler.class);
            registerC(DoActChooseGiftRq.EXT_FIELD_NUMBER, DoActChooseGiftRs.EXT_FIELD_NUMBER, DoActChooseGiftHandler.class);

            // 新活跃度
            registerC(NewGetLiveTaskRq.EXT_FIELD_NUMBER, NewGetLiveTaskRs.EXT_FIELD_NUMBER, NewGetLiveTaskHandler.class);
            registerC(NewTaskLiveAwardRq.EXT_FIELD_NUMBER, NewTaskLiveAwardRs.EXT_FIELD_NUMBER, NewTaskLiveAwardHandler.class);

            // 军衔相关
            registerC(GetMilitaryRankRq.EXT_FIELD_NUMBER, GetMilitaryRankRs.EXT_FIELD_NUMBER, GetMilitaryRankHandler.class);
            registerC(UpMilitaryRankRq.EXT_FIELD_NUMBER, UpMilitaryRankRs.EXT_FIELD_NUMBER, UpMilitaryRankHandler.class);

            // 皮肤管理
            registerC(BuySkinRq.EXT_FIELD_NUMBER, BuySkinRs.EXT_FIELD_NUMBER, BuySkinHandler.class);
            registerC(UseSkinRq.EXT_FIELD_NUMBER, UseSkinRs.EXT_FIELD_NUMBER, UseSkinHandler.class);
            registerC(GetSkinsRq.EXT_FIELD_NUMBER, GetSkinsRs.EXT_FIELD_NUMBER, GetSkinsHandler.class);

            // 兄弟同心
            registerC(GetActBrotherTaskRq.EXT_FIELD_NUMBER, GetActBrotherTaskRs.EXT_FIELD_NUMBER, GetActBrotherTaskHandler.class);
            registerC(UpBrotherBuffRq.EXT_FIELD_NUMBER, UpBrotherBuffRs.EXT_FIELD_NUMBER, UpBrotherBuffHandler.class);
            registerC(GetBrotherAwardRq.EXT_FIELD_NUMBER, GetBrotherAwardRs.EXT_FIELD_NUMBER, GetBrotherAwardHandler.class);

            //
            registerC(ShowQuinnRq.EXT_FIELD_NUMBER, ShowQuinnRs.EXT_FIELD_NUMBER, ShowQuinnHandler.class);
            registerC(BuyQuinnRq.EXT_FIELD_NUMBER, BuyQuinnRs.EXT_FIELD_NUMBER, BuyQuinnHandler.class);
            registerC(GetQuinnAwardRq.EXT_FIELD_NUMBER, GetQuinnAwardRs.EXT_FIELD_NUMBER, GetQuinnAwardHandler.class);

            // 荣誉勋章活动
            registerC(GetActMedalofhonorInfoRq.EXT_FIELD_NUMBER, GetActMedalofhonorInfoRs.EXT_FIELD_NUMBER, GetActMedalofhonorInfoHandler.class);
            registerC(OpenActMedalofhonorRq.EXT_FIELD_NUMBER, OpenActMedalofhonorRs.EXT_FIELD_NUMBER, OpenActMedalofhonorHandler.class);
            registerC(SearchActMedalofhonorTargetsRq.EXT_FIELD_NUMBER, SearchActMedalofhonorTargetsRs.EXT_FIELD_NUMBER,
                    SearchActMedalofhonorTargetsHandler.class);
            registerC(BuyActMedalofhonorItemRq.EXT_FIELD_NUMBER, BuyActMedalofhonorItemRs.EXT_FIELD_NUMBER, BuyActMedalofhonorItemHandler.class);
            registerC(GetActMedalofhonorRankInfoRq.EXT_FIELD_NUMBER, GetActMedalofhonorRankInfoRs.EXT_FIELD_NUMBER,
                    GetMedalofhonorRankInfoHandler.class);
            registerC(GetActMedalofhonorRankAwardRq.EXT_FIELD_NUMBER, GetActMedalofhonorRankAwardRs.EXT_FIELD_NUMBER,
                    GetMedalofhonorRankAwardHandler.class);

            // 秘密武器
            registerC(GetSecretWeaponInfoRq.EXT_FIELD_NUMBER, GetSecretWeaponInfoRs.EXT_FIELD_NUMBER, GetSecretWeaponInfoHandler.class);
            registerC(LockedWeaponBarRq.EXT_FIELD_NUMBER, LockedWeaponBarRs.EXT_FIELD_NUMBER, LockedWeaponBarHandler.class);
            registerC(UnlockWeaponBarRq.EXT_FIELD_NUMBER, UnlockWeaponBarRs.EXT_FIELD_NUMBER, UnlockWeaponBarHandler.class);
            registerC(StudyWeaponSkillRq.EXT_FIELD_NUMBER, StudyWeaponSkillRs.EXT_FIELD_NUMBER, StudyWeaponSkillHandler.class);

            // 攻击特效
            registerC(GetAttackEffectRq.EXT_FIELD_NUMBER, GetAttackEffectRs.EXT_FIELD_NUMBER, GetAttackEffectHandler.class);
            registerC(UseAttackEffectRq.EXT_FIELD_NUMBER, UseAttackEffectRs.EXT_FIELD_NUMBER, UseAttackEffectHandler.class);

            // 大富翁(圣诞宝藏)活动
            registerC(GetMonopolyInfoRq.EXT_FIELD_NUMBER, GetMonopolyInfoRs.EXT_FIELD_NUMBER, GetMonopolyInfoHandler.class);
            registerC(BuyDiscountGoodsRq.EXT_FIELD_NUMBER, BuyDiscountGoodsRs.EXT_FIELD_NUMBER, BuyDiscountGoodsHandler.class);
            registerC(BuyOrUseEnergyRq.EXT_FIELD_NUMBER, BuyOrUseEnergyRs.EXT_FIELD_NUMBER, BuyOrUseEnergyHandler.class);
            registerC(SelectDialogRq.EXT_FIELD_NUMBER, SelectDialogRs.EXT_FIELD_NUMBER, SelectDialogHandler.class);
            registerC(ThrowDiceRq.EXT_FIELD_NUMBER, ThrowDiceRs.EXT_FIELD_NUMBER, ThrowDiceHandler.class);
            registerC(DrawFreeEnergyRq.EXT_FIELD_NUMBER, DrawFreeEnergyRs.EXT_FIELD_NUMBER, DrawFreeEnergyHandler.class);
            registerC(DrawFinishCountAwardRq.EXT_FIELD_NUMBER, DrawFinishCountAwardRs.EXT_FIELD_NUMBER, DrawFinishCountAwardHandler.class);

            // 外挂处理
            // 扫矿外挂处理
            registerC(PlugInScoutMineValidCodeRq.EXT_FIELD_NUMBER, PlugInScoutMineValidCodeRs.EXT_FIELD_NUMBER,
                    PlugInScoutMineValidCodeHandler.class);

            // 作战研究院
            registerC(ActFightLabArchActRq.EXT_FIELD_NUMBER, ActFightLabArchActRs.EXT_FIELD_NUMBER, ActFightLabArchActHandler.class);
            registerC(GetFightLabGraduateInfoRq.EXT_FIELD_NUMBER, GetFightLabGraduateInfoRs.EXT_FIELD_NUMBER, GetFightLabGraduateInfoHandler.class);
            registerC(GetFightLabGraduateRewardRq.EXT_FIELD_NUMBER, GetFightLabGraduateRewardRs.EXT_FIELD_NUMBER,
                    GetFightLabGraduateRewardHandler.class);
            registerC(GetFightLabInfoRq.EXT_FIELD_NUMBER, GetFightLabInfoRs.EXT_FIELD_NUMBER, GetFightLabInfoHandler.class);
            registerC(GetFightLabItemInfoRq.EXT_FIELD_NUMBER, GetFightLabItemInfoRs.EXT_FIELD_NUMBER, GetFightLabItemInfoHandler.class);
            registerC(GetFightLabResourceRq.EXT_FIELD_NUMBER, GetFightLabResourceRs.EXT_FIELD_NUMBER, GetFightLabResourceHandler.class);
            registerC(SetFightLabPersonCountRq.EXT_FIELD_NUMBER, SetFightLabPersonCountRs.EXT_FIELD_NUMBER, SetFightLabPersonCountHandler.class);
            registerC(UpFightLabGraduateUpRq.EXT_FIELD_NUMBER, UpFightLabGraduateUpRs.EXT_FIELD_NUMBER, UpFightLabGraduateUpHandler.class);
            registerC(UpFightLabTechUpLevelRq.EXT_FIELD_NUMBER, UpFightLabTechUpLevelRs.EXT_FIELD_NUMBER, UpFightLabTechUpLevelHandler.class);

            registerC(ActFightLabSpyAreaRq.EXT_FIELD_NUMBER, ActFightLabSpyAreaRs.EXT_FIELD_NUMBER, ActFightLabSpyAreaHandler.class);
            registerC(ActFightLabSpyTaskRq.EXT_FIELD_NUMBER, ActFightLabSpyTaskRs.EXT_FIELD_NUMBER, ActFightLabSpyTaskHandler.class);
            registerC(GctFightLabSpyTaskRewardRq.EXT_FIELD_NUMBER, GctFightLabSpyTaskRewardRs.EXT_FIELD_NUMBER,
                    GctFightLabSpyTaskRewardHandler.class);
            registerC(GetFightLabSpyInfoRq.EXT_FIELD_NUMBER, GetFightLabSpyInfoRs.EXT_FIELD_NUMBER, GetFightLabSpyInfoHandler.class);
            registerC(RefFightLabSpyTaskRq.EXT_FIELD_NUMBER, RefFightLabSpyTaskRs.EXT_FIELD_NUMBER, RefFightLabSpyTaskHandler.class);
            registerC(ResetFightLabGraduateUpRq.EXT_FIELD_NUMBER, ResetFightLabGraduateUpRs.EXT_FIELD_NUMBER, ResetFightLabGraduateUpHandler.class);

            registerC(GetGiftRewardRq.EXT_FIELD_NUMBER, GetGiftRewardRs.EXT_FIELD_NUMBER, GetGiftRewardHandler.class);
            registerC(GetGuideRewardRq.EXT_FIELD_NUMBER, GetGuideRewardRs.EXT_FIELD_NUMBER, GetGuideRewardRqHandler.class);

            // 红包活动
            registerC(GetActRedBagInfoRq.EXT_FIELD_NUMBER, GetActRedBagInfoRs.EXT_FIELD_NUMBER, ActRedBagInfoHandler.class);
            registerC(GetActRedBagListRq.EXT_FIELD_NUMBER, GetActRedBagListRs.EXT_FIELD_NUMBER, ActRedBagListHandler.class);
            registerC(DrawActRedBagStageAwardRq.EXT_FIELD_NUMBER, DrawActRedBagStageAwardRs.EXT_FIELD_NUMBER, DrawActRedBagStageAwardHandler.class);
            registerC(GrabRedBagRq.EXT_FIELD_NUMBER, GrabRedBagRs.EXT_FIELD_NUMBER, GrabRedBagHandler.class);
            registerC(SendActRedBagRq.EXT_FIELD_NUMBER, SendActRedBagRs.EXT_FIELD_NUMBER, SendActRedBagHandler.class);

            // 红色方案
            registerC(GetRedPlanBoxRq.EXT_FIELD_NUMBER, GetRedPlanBoxRs.EXT_FIELD_NUMBER, GetRedPlanBoxRqHandler.class);
            registerC(GetRedPlanInfoRq.EXT_FIELD_NUMBER, GetRedPlanInfoRs.EXT_FIELD_NUMBER, GetRedPlanInfoHandler.class);
            registerC(MoveRedPlanRq.EXT_FIELD_NUMBER, MoveRedPlanRs.EXT_FIELD_NUMBER, MoveRedPlanRqHandler.class);
            registerC(RedPlanBuyFuelRq.EXT_FIELD_NUMBER, RedPlanBuyFuelRs.EXT_FIELD_NUMBER, RedPlanBuyFuelRqHandler.class);
            registerC(RedPlanRewardRq.EXT_FIELD_NUMBER, RedPlanRewardRs.EXT_FIELD_NUMBER, RedPlanRewardRqHandler.class);
            registerC(GetRedPlanAreaInfoRq.EXT_FIELD_NUMBER, GetRedPlanAreaInfoRs.EXT_FIELD_NUMBER, GetRedPlanAreaInfoRqHandler.class);
            registerC(RefRedPlanAreaRq.EXT_FIELD_NUMBER, RefRedPlanAreaRs.EXT_FIELD_NUMBER, RefRedPlanAreaRqHandler.class);

            // 组队副本
            registerC(CreateTeamRq.EXT_FIELD_NUMBER, CreateTeamRs.EXT_FIELD_NUMBER, CreateTeamHandler.class);
            registerC(LeaveTeamRq.EXT_FIELD_NUMBER, LeaveTeamRs.EXT_FIELD_NUMBER, LeaveTeamHandler.class);
            registerC(DismissTeamRq.EXT_FIELD_NUMBER, DismissTeamRs.EXT_FIELD_NUMBER, DismissTeamHandler.class);
            registerC(JoinTeamRq.EXT_FIELD_NUMBER, JoinTeamRs.EXT_FIELD_NUMBER, JoinTeamHandler.class);
            registerC(KickOutRq.EXT_FIELD_NUMBER, KickOutRs.EXT_FIELD_NUMBER, KickOutHandler.class);
            registerC(FindTeamRq.EXT_FIELD_NUMBER, FindTeamRs.EXT_FIELD_NUMBER, FindTeamHandler.class);
            registerC(ChangeMemberStatusRq.EXT_FIELD_NUMBER, ChangeMemberStatusRs.EXT_FIELD_NUMBER, ChangeMemberStatusHandler.class);
            registerC(ExchangeOrderRq.EXT_FIELD_NUMBER, ExchangeOrderRs.EXT_FIELD_NUMBER, ExchangeTeamOrderHandler.class);
            registerC(TeamChatRq.EXT_FIELD_NUMBER, TeamChatRs.EXT_FIELD_NUMBER, TeamChatHandler.class);
            registerC(TeamInstanceExchangeRq.EXT_FIELD_NUMBER, TeamInstanceExchangeRs.EXT_FIELD_NUMBER, TeamInstanceExchangeHandler.class);
            registerC(InviteMemberRq.EXT_FIELD_NUMBER, InviteMemberRs.EXT_FIELD_NUMBER, InviteMemberHandler.class);
            registerC(LookMemberInfoRq.EXT_FIELD_NUMBER, LookMemberInfoRs.EXT_FIELD_NUMBER, LookFormHandler.class);
            registerC(TeamFightBossRq.EXT_FIELD_NUMBER, TeamFightBossRs.EXT_FIELD_NUMBER, TeamFightBossHandler.class);
            registerC(GetBountyShopBuyRq.EXT_FIELD_NUMBER, GetBountyShopBuyRs.EXT_FIELD_NUMBER, GetBountyShopBuyHandler.class);
            registerC(GetTaskRewardStatusRq.EXT_FIELD_NUMBER, GetTaskRewardStatusRs.EXT_FIELD_NUMBER, GetTaskStatusHandler.class);
            registerC(GetTaskRewardRq.EXT_FIELD_NUMBER, GetTaskRewardRs.EXT_FIELD_NUMBER, GetTaskRewardHandler.class);
            registerC(GetTeamFightBossInfoRq.EXT_FIELD_NUMBER, GetTeamFightBossInfoRs.EXT_FIELD_NUMBER, GetTeamFightBossInfoHandler.class);

            // 假日碎片
            registerC(GetFestivalInfoRq.EXT_FIELD_NUMBER, GetFestivalInfoRs.EXT_FIELD_NUMBER, GetFestivalInfoRqHandler.class);
            registerC(GetFestivalRewardRq.EXT_FIELD_NUMBER, GetFestivalRewardRs.EXT_FIELD_NUMBER, GetFestivalRewardRqHandler.class);
            registerC(GetFestivalLoginRewardRq.EXT_FIELD_NUMBER, GetFestivalLoginRewardRs.EXT_FIELD_NUMBER, GetFestivalLoginRewardRqHandler.class);
            registerC(GetActNewPayInfoRq.EXT_FIELD_NUMBER, GetActNewPayInfoRs.EXT_FIELD_NUMBER, GetActNewPayInfoRqHandler.class);
            registerC(GetActNew2PayInfoRq.EXT_FIELD_NUMBER, GetActNew2PayInfoRs.EXT_FIELD_NUMBER, GetActNew2PayInfoRqHandler.class);
            // 幸运奖池
            registerC(GetActLuckyInfoRq.EXT_FIELD_NUMBER, GetActLuckyInfoRs.EXT_FIELD_NUMBER, GetActLuckyInfoRqHandler.class);
            registerC(GetActLuckyRewardRq.EXT_FIELD_NUMBER, GetActLuckyRewardRs.EXT_FIELD_NUMBER, GetActLuckyRewardRqHandler.class);
            registerC(GetActLuckyPoolLogRq.EXT_FIELD_NUMBER, GetActLuckyPoolLogRs.EXT_FIELD_NUMBER, GetActLuckyPoolLogHandler.class);


            //叛军优化
            registerC(GetRebelBoxAwardRq.EXT_FIELD_NUMBER, GetRebelBoxAwardRs.EXT_FIELD_NUMBER, RebelBoxRewardHandler.class);
            registerC(GrabRebelRedBagRq.EXT_FIELD_NUMBER, GrabRebelRedBagRs.EXT_FIELD_NUMBER, GrabRebelRedBagHandler.class);

            //配件转换
            registerC(PartConvertRq.EXT_FIELD_NUMBER, PartConvertRs.EXT_FIELD_NUMBER, PartConvertHandler.class);

            //坦克转换
            registerC(GetTankConvertInfoRq.EXT_FIELD_NUMBER, GetTankConvertInfoRs.EXT_FIELD_NUMBER, GetTankConvertInfoHandler.class);
            registerC(TankConvertRq.EXT_FIELD_NUMBER, TankConvertRs.EXT_FIELD_NUMBER, TankConvertHanlder.class);

            //军备图纸兑换
            registerC(DoDrawingCashRq.EXT_FIELD_NUMBER, DoDrawingCashRs.EXT_FIELD_NUMBER, DoDrawingCashHanlder.class);
            registerC(RefshDrawingCashRq.EXT_FIELD_NUMBER, RefshDrawingCashRs.EXT_FIELD_NUMBER, RefshDrawingCashHanlder.class);
            registerC(GetDrawingCashRq.EXT_FIELD_NUMBER, GetDrawingCashRs.EXT_FIELD_NUMBER, GetDrawingCashHanlder.class);

            //幸运转盘每日目标
            registerC(GetActFortuneDayInfoRq.EXT_FIELD_NUMBER, GetActFortuneDayInfoRs.EXT_FIELD_NUMBER, GetActFortuneDayInfoHanlder.class);
            registerC(GetFortuneDayAwardRq.EXT_FIELD_NUMBER, GetFortuneDayAwardRs.EXT_FIELD_NUMBER, GetFortuneDayAwardHanlder.class);

            //能晶转盘每日目标
            registerC(GetEnergyDialDayInfoRq.EXT_FIELD_NUMBER, GetEnergyDialDayInfoRs.EXT_FIELD_NUMBER, GetEnergyDialDayInfofoHanlder.class);
            registerC(GetEnergyDialDayAwardRq.EXT_FIELD_NUMBER, GetEnergyDialDayAwardRs.EXT_FIELD_NUMBER, GetEnergyDialDayAwardHanlder.class);

            //装备转盘
            registerC(GetActEquipDialRq.EXT_FIELD_NUMBER, GetActEquipDialRs.EXT_FIELD_NUMBER, GetActEquipDialHanlder.class);
            registerC(GetActEquipDialRankRq.EXT_FIELD_NUMBER, GetActEquipDialRankRs.EXT_FIELD_NUMBER, GetActEquipDialRankHanlder.class);
            registerC(DoActEquipDialRq.EXT_FIELD_NUMBER, DoActEquipDialRs.EXT_FIELD_NUMBER, DoActEquipDialHandler.class);
            registerC(GetEquipDialDayInfoRq.EXT_FIELD_NUMBER, GetEquipDialDayInfoRs.EXT_FIELD_NUMBER, GetEquipDialDayInfoHandler.class);
            registerC(GetEquipDialDayAwardRq.EXT_FIELD_NUMBER, GetEquipDialDayAwardRs.EXT_FIELD_NUMBER, GetEquipDialDayAwardHandler.class);

            //勋章分解兑换
            registerC(GetActMedalResolveRq.EXT_FIELD_NUMBER, GetActMedalResolveRs.EXT_FIELD_NUMBER, GetActMedalResolveHandler.class);
            registerC(DoActMedalResolveRq.EXT_FIELD_NUMBER, DoActMedalResolveRs.EXT_FIELD_NUMBER, DoActMedalResolveHandler.class);
            registerC(QuickUpMedalRq.EXT_FIELD_NUMBER, QuickUpMedalRs.EXT_FIELD_NUMBER, QuickUpMedalHandler.class);

            //优化，兑换及购买类活动批量操作
            registerC(BuyInBuckRq.EXT_FIELD_NUMBER, BuyInBuckRs.EXT_FIELD_NUMBER, BuyInBuckHandler.class);
            //新活跃礼盒
            registerC(GetActiveBoxAwardRq.EXT_FIELD_NUMBER, GetActiveBoxAwardRs.EXT_FIELD_NUMBER, GetActiveBoxAwardHandler.class);

            //荣耀生存
            registerC(GetHonourRankRq.EXT_FIELD_NUMBER, GetHonourRankRs.EXT_FIELD_NUMBER, GetHonourRankHandler.class);
            registerC(GetHonourRankAwardRq.EXT_FIELD_NUMBER, GetHonourRankAwardRs.EXT_FIELD_NUMBER, GetHonourRankAwardHandler.class);
            registerC(HonourCollectInfoRq.EXT_FIELD_NUMBER, HonourCollectInfoRs.EXT_FIELD_NUMBER, HonourCollectInfoHandler.class);
            registerC(GetHonourStatusRq.EXT_FIELD_NUMBER, GetHonourStatusRs.EXT_FIELD_NUMBER, GetHonourStatusHandler.class);
            registerC(GetHonourScoreGoldRq.EXT_FIELD_NUMBER, GetHonourScoreGoldRs.EXT_FIELD_NUMBER, GetHonourScoreGoldHandler.class);
            registerC(HonourScoreGoldInfoRq.EXT_FIELD_NUMBER, HonourScoreGoldInfoRs.EXT_FIELD_NUMBER, HonourScoreGoldInfoHandler.class);

            //登陆福利
            registerC(GetLoginWelfareInfoRq.EXT_FIELD_NUMBER, GetLoginWelfareInfoRs.EXT_FIELD_NUMBER, GetLoginWelfareInfoHandler.class);
            registerC(GetLoginWelfareAwardRq.EXT_FIELD_NUMBER, GetLoginWelfareAwardRs.EXT_FIELD_NUMBER, GetLoginWelfareAwardHandler.class);


            registerC(GetBoxInfoRq.EXT_FIELD_NUMBER, GetBoxInfoRs.EXT_FIELD_NUMBER, GetBoxInfoRqHandler.class);
            registerC(BuyBoxRq.EXT_FIELD_NUMBER, BuyBoxRs.EXT_FIELD_NUMBER, BuyBoxRqHandler.class);
            registerC(GetScoutFreeTimeRq.EXT_FIELD_NUMBER, GetScoutFreeTimeRs.EXT_FIELD_NUMBER, GetScoutFreeTimeRqHandler.class);
            registerC(VCodeScoutRq.EXT_FIELD_NUMBER, VCodeScoutRs.EXT_FIELD_NUMBER, VCodeScoutRqHandler.class);
            registerC(RefreshScoutImgRq.EXT_FIELD_NUMBER, RefreshScoutImgRs.EXT_FIELD_NUMBER, RefreshScoutImgHandler.class);
            registerC(ActBuildInfoRq.EXT_FIELD_NUMBER, ActBuildInfoRs.EXT_FIELD_NUMBER, ActBuildInfoHandler.class);


            //新英雄采集
            registerC(GetNewHeroInfoRq.EXT_FIELD_NUMBER, GetNewHeroInfoRs.EXT_FIELD_NUMBER, GetNewHeroInfoRqHandler.class);
            registerC(ClearHeroCdRq.EXT_FIELD_NUMBER, ClearHeroCdRs.EXT_FIELD_NUMBER, ClearHeroCdRqHandler.class);
            registerC(GetHeroCdRq.EXT_FIELD_NUMBER, GetHeroCdRs.EXT_FIELD_NUMBER, GetHeroCdRqHandler.class);
            registerC(GetHeroEndTimeRq.EXT_FIELD_NUMBER, GetHeroEndTimeRs.EXT_FIELD_NUMBER, GetHeroEndTimeRqHandler.class);

            // 一键领取
            registerC(GetAllPcbtAwardRq.EXT_FIELD_NUMBER, GetAllPcbtAwardRs.EXT_FIELD_NUMBER, GetAllPcbtAwardHandler.class);
            registerC(DonateAllPartyResRq.EXT_FIELD_NUMBER, DonateAllPartyResRs.EXT_FIELD_NUMBER, DonateAllPartyResHandler.class);
            registerC(DonateAllPartyScienceRq.EXT_FIELD_NUMBER, DonateAllPartyScienceRs.EXT_FIELD_NUMBER, DonateAllPartyScienceHandler.class);
            registerC(GetAllSpyTaskRewardRq.EXT_FIELD_NUMBER, GetAllSpyTaskRewardRs.EXT_FIELD_NUMBER, GetAllSpyTaskRewardHandler.class);

            // 问卷调查
            registerC(QueSendAnswerRq.EXT_FIELD_NUMBER, QueSendAnswerRs.EXT_FIELD_NUMBER, QueSendAnswerHandler.class);
            registerC(GetQueAwardStatusRq.EXT_FIELD_NUMBER, GetQueAwardStatusRs.EXT_FIELD_NUMBER, GetQueAwardStatusHandler.class);


            registerC(GetWorldStaffingRq.EXT_FIELD_NUMBER, GetWorldStaffingRs.EXT_FIELD_NUMBER, GetWorldStaffingRqHandler.class);

            registerC(SetLordEquipUseTypeRq.EXT_FIELD_NUMBER, SetLordEquipUseTypeRs.EXT_FIELD_NUMBER, SetLordEquipUseTypeRqHandler.class);
            registerC(LordEquipInheritRq.EXT_FIELD_NUMBER, LordEquipInheritRs.EXT_FIELD_NUMBER, LordEquipInheritRqHandler.class);


            registerC(GetWarActivityInfoRq.EXT_FIELD_NUMBER, GetWarActivityInfoRs.EXT_FIELD_NUMBER, GetWarActivityInfoRqHandler.class);
            registerC(GetWarActivityRewardRq.EXT_FIELD_NUMBER, GetWarActivityRewardRs.EXT_FIELD_NUMBER, GetWarActivityRewardRqHandler.class);


            //
            registerC(GetFeedAltarBossRq.EXT_FIELD_NUMBER, GetFeedAltarBossRs.EXT_FIELD_NUMBER, GetFeedAltarBossRqHandler.class);
            registerC(GetFeedAltarContriButeRq.EXT_FIELD_NUMBER, GetFeedAltarContriButeRs.EXT_FIELD_NUMBER, DonateAltarBossContriBute.class);


            //最强王者
            registerC(GetAllRanksRq.EXT_FIELD_NUMBER, GetAllRanksRs.EXT_FIELD_NUMBER, GetAllRanksRqHandler.class);
            registerC(GetKingAwardRq.EXT_FIELD_NUMBER, GetKingAwardRs.EXT_FIELD_NUMBER, GetKingAwardRqHandler.class);
            registerC(GetKingRankAwardRq.EXT_FIELD_NUMBER, GetKingRankAwardRs.EXT_FIELD_NUMBER, GetKingRankAwardRqHandler.class);
            registerC(GetPsnKillRankRq.EXT_FIELD_NUMBER, GetPsnKillRankRs.EXT_FIELD_NUMBER, GetPsnKillRankRqHandler.class);
            registerC(GetRanksInfoRq.EXT_FIELD_NUMBER, GetRanksInfoRs.EXT_FIELD_NUMBER, GetRanksInfoRqHandler.class);

            //战术大师
            registerC(AdvancedTacticsRq.EXT_FIELD_NUMBER, AdvancedTacticsRs.EXT_FIELD_NUMBER, AdvancedTacticsRqHandler.class);
            registerC(ComposeTacticsRq.EXT_FIELD_NUMBER, ComposeTacticsRs.EXT_FIELD_NUMBER, ComposeTacticsRqHandler.class);
            registerC(GetTacticsRq.EXT_FIELD_NUMBER, GetTacticsRs.EXT_FIELD_NUMBER, GetTacticsRqHandler.class);
            registerC(TpTacticsRq.EXT_FIELD_NUMBER, TpTacticsRs.EXT_FIELD_NUMBER, TpTacticsRqHandler.class);
            registerC(UpgradeTacticsRq.EXT_FIELD_NUMBER, UpgradeTacticsRs.EXT_FIELD_NUMBER, UpgradeTacticsRqHandler.class);
            registerC(SetTacticsFormRq.EXT_FIELD_NUMBER, SetTacticsFormRs.EXT_FIELD_NUMBER, SetTacticsFormRqHandler.class);
            registerC(BindTacticsFormRq.EXT_FIELD_NUMBER, BindTacticsFormRs.EXT_FIELD_NUMBER, BindTacticsFormRqHandler.class);


            //一键扫荡
            registerC(GetWipeInfoRq.EXT_FIELD_NUMBER, GetWipeInfoRs.EXT_FIELD_NUMBER, GetWipeInfoRqHandler.class);
            registerC(GetWipeRewarRq.EXT_FIELD_NUMBER, GetWipeRewarRs.EXT_FIELD_NUMBER, GetWipeRewarRqHandler.class);
            registerC(SetWipeInfoRq.EXT_FIELD_NUMBER, SetWipeInfoRs.EXT_FIELD_NUMBER, SetWipeInfoRqHandler.class);

            //好友赠送物品道具
            registerC(FriendGivePropRq.EXT_FIELD_NUMBER, FriendGivePropRs.EXT_FIELD_NUMBER, FriendGivePropHandler.class);


            //能源核心
            registerC(EnergyCoreRq.EXT_FIELD_NUMBER, EnergyCoreRs.EXT_FIELD_NUMBER, EnergyCoreInfoHandler.class);
            registerC(SmeltCoreEquipRq.EXT_FIELD_NUMBER, SmeltCoreEquipRs.EXT_FIELD_NUMBER, SmeltEnergyCoreHandler.class);


            // 战术转盘
            registerC(GetActTicDialRq.EXT_FIELD_NUMBER, GetActTicDialRs.EXT_FIELD_NUMBER, ActTicHandler.class);
            registerC(GetActTicDialRankRq.EXT_FIELD_NUMBER, GetActTicDialRankRs.EXT_FIELD_NUMBER, ActTicRankHandler.class);
            registerC(DoActTicDialRq.EXT_FIELD_NUMBER, DoActTicDialRs.EXT_FIELD_NUMBER, ActTicGetHandler.class);

            //战术转盘每日目标
            registerC(GetTicDialDayInfoRq.EXT_FIELD_NUMBER, GetTicDialDayInfoRs.EXT_FIELD_NUMBER, ActTicDayInfoHandler.class);
            registerC(GetTicDialDayAwardRq.EXT_FIELD_NUMBER, GetTicDialDayAwardRs.EXT_FIELD_NUMBER, ActTicGetDayAwardHandler.class);

            //拉跨服服务器列表
            registerC(GetCrossServerInfoRq.EXT_FIELD_NUMBER, GetCrossServerInfoRs.EXT_FIELD_NUMBER, QueryCrossServerListHandler.class);

            //跨服军矿
            registerC(GetCrossSeniorMapRq.EXT_FIELD_NUMBER, GetCrossSeniorMapRs.EXT_FIELD_NUMBER, CrossMineMapHandler.class);
            registerC(SctCrossSeniorMineRq.EXT_FIELD_NUMBER, SctCrossSeniorMineRs.EXT_FIELD_NUMBER, CrossMineScoutHandler.class);
            registerC(AtkCrossSeniorMineRq.EXT_FIELD_NUMBER, AtkCrossSeniorMineRs.EXT_FIELD_NUMBER, CrossMineAttackHandler.class);
            registerC(CrossScoreRankRq.EXT_FIELD_NUMBER, CrossScoreRankRs.EXT_FIELD_NUMBER, CrossMineCheckScoreHandler.class);
            registerC(CrossScoreAwardRq.EXT_FIELD_NUMBER, CrossScoreAwardRs.EXT_FIELD_NUMBER, CrossMineGetScoreAwardHandler.class);
            registerC(CrossServerScoreRankRq.EXT_FIELD_NUMBER, CrossServerScoreRankRs.EXT_FIELD_NUMBER, CrossMineServerRankHandler.class);
            registerC(CrossServerScoreAwardRq.EXT_FIELD_NUMBER, CrossServerScoreAwardRs.EXT_FIELD_NUMBER, CrossMineAwardHandler.class);


            // ss
            registerS(VerifyRs.EXT_FIELD_NUMBER, BeginGameRs.EXT_FIELD_NUMBER, VerifyRsHandler.class);
            registerS(RegisterRs.EXT_FIELD_NUMBER, 0, RegisterRsHandler.class);
            registerS(UseGiftCodeRs.EXT_FIELD_NUMBER, GiftCodeRs.EXT_FIELD_NUMBER, UseGiftCodeRsHandler.class);
            registerS(PayBackRq.EXT_FIELD_NUMBER, 0, PayBackRqHandler.class);
            registerS(SendToMailRq.EXT_FIELD_NUMBER, 0, SendToMailRqHandler.class);
            registerS(ForbiddenRq.EXT_FIELD_NUMBER, 0, ForbiddenRqHandler.class);
            registerS(GetLordBaseRq.EXT_FIELD_NUMBER, 0, GetLordBaseRqHandler.class);
            registerS(ModVipRq.EXT_FIELD_NUMBER, 0, ModVipRqHandler.class);
            registerS(NoticeRq.EXT_FIELD_NUMBER, 0, NoticeRqHandler.class);
            registerS(CensusBaseRq.EXT_FIELD_NUMBER, 0, CensusBaseRqHandler.class);
            registerS(ModLordRq.EXT_FIELD_NUMBER, 0, ModLordRqHandler.class);
            registerS(ReloadParamRq.EXT_FIELD_NUMBER, 0, ReloadParamRqHandler.class);
            registerS(NotifyCrossOnLineRq.EXT_FIELD_NUMBER, 0, NotifyCrossOnLineHandler.class);
            registerS(GetRankBaseRq.EXT_FIELD_NUMBER, 0, GetRankBaseRqHandler.class);
            registerS(GetPartyMembersRq.EXT_FIELD_NUMBER, 0, GetPartyMembersRqHandler.class);
            registerS(ModPartyMemberJobRq.EXT_FIELD_NUMBER, 0, ModPartyMemberJobRqHandler.class);
            registerS(RecalcResourceRq.EXT_FIELD_NUMBER, 0, RecalcRqHandler.class);
            registerS(ModPropRq.EXT_FIELD_NUMBER, 0, ModPropRqHandler.class);
            registerS(ModNameRq.EXT_FIELD_NUMBER, 0, ModNameRqHandler.class);
            registerS(ChangePlatNoRq.EXT_FIELD_NUMBER, 0, ChangePlatNoRqHandler.class);
            registerS(InnerPb.LordRelevanceRq.EXT_FIELD_NUMBER, 0, LordRelevanceRqHandler.class);
            registerS(InnerPb.HotfixClassRq.EXT_FIELD_NUMBER, 0, HotfixHandler.class);
            registerS(InnerPb.ExecutHotfixRq.EXT_FIELD_NUMBER, 0, ExecuteHotfixHandler.class);
            registerS(InnerPb.AddAttackFreeBuffRq.EXT_FIELD_NUMBER, 0, AddAttackFreeBuffHandler.class);

            registerS(CrossMinPb.CrossMinNotifyRq.EXT_FIELD_NUMBER, 0, CrossMinNotifyRqHandler.class);
            registerS(InnerPb.GetEnergyBaseRq.EXT_FIELD_NUMBER, 0, GetEnergyInfoHandler.class);





            // cross
            registerI(CCGameServerRegRs.EXT_FIELD_NUMBER, CCGameServerRegHandler.class);
            registerI(CCGetCrossServerListRs.EXT_FIELD_NUMBER, CCGetCrossServerListHandler.class);
            registerI(CCGetCrossFightStateRs.EXT_FIELD_NUMBER, CCGetCrossFightStateHandler.class);
            registerI(CCSynChatRq.EXT_FIELD_NUMBER, CCSynChatHandler.class);
            registerI(CCCrossFightRegRs.EXT_FIELD_NUMBER, CCCrossFightRegHandler.class);
            registerI(CCGetCrossRegInfoRs.EXT_FIELD_NUMBER, CCGetCrossRegInfoHandler.class);
            registerI(CCCancelCrossRegRs.EXT_FIELD_NUMBER, CCCancelCrossRegHandler.class);
            registerI(CCGetCrossFormRs.EXT_FIELD_NUMBER, CCGetCrossFormHandler.class);
            registerI(CCSetCrossFormRs.EXT_FIELD_NUMBER, CCSetCrossFormHandler.class);
            registerI(CCGetCrossPersonSituationRs.EXT_FIELD_NUMBER, CCGetCrossPersonSituationHandler.class);
            registerI(CCGetCrossJiFenRankRs.EXT_FIELD_NUMBER, CCGetCrossJiFenRankHandler.class);
            registerI(CCGetCrossReportRs.EXT_FIELD_NUMBER, CCGetCrossReportHandler.class);
            registerI(CCGetCrossKnockCompetInfoRs.EXT_FIELD_NUMBER, CCGetCrossKnockCompetInfoHandler.class);
            registerI(CCGetCrossFinalCompetInfoRs.EXT_FIELD_NUMBER, CCGetCrossFinalCompetInfoHandler.class);
            registerI(CCBetBattleRs.EXT_FIELD_NUMBER, CCBetBattleHandler.class);
            registerI(CCGetMyBetRs.EXT_FIELD_NUMBER, CCGetMyBetHandler.class);
            registerI(CCReceiveBetRs.EXT_FIELD_NUMBER, CCReceiveBetHanlder.class);
            registerI(CCGetCrossShopRs.EXT_FIELD_NUMBER, CCGetCrossShopHandler.class);
            registerI(CCExchangeCrossShopRs.EXT_FIELD_NUMBER, CCExchangeCrossShopHandler.class);
            registerI(CCGetCrossFinalRankRs.EXT_FIELD_NUMBER, CCGetCrossFinalRankHandler.class);
            registerI(CCReceiveRankRwardRs.EXT_FIELD_NUMBER, CCReceiveRankRwardHandler.class);
            registerI(CCSynMailRq.EXT_FIELD_NUMBER, CCSynMailHandler.class);
            registerI(CCGetCrossTrendRs.EXT_FIELD_NUMBER, CCGetCrossTrendHandler.class);
            registerI(CCSynCrossStateRq.EXT_FIELD_NUMBER, CCSynCrossStateHandler.class);
            registerI(CCHeartRs.EXT_FIELD_NUMBER, CCHeartHandler.class);
            registerI(CCSynCrossFameRq.EXT_FIELD_NUMBER, CCSynCrossFameHandler.class);

            // crossParty
            registerI(CCGetCrossPartyStateRs.EXT_FIELD_NUMBER, CCGetCrossPartyStateHandler.class);
            registerI(CCGetCrossPartyServerListRs.EXT_FIELD_NUMBER, CCGetCrossPartyServerListHandler.class);
            registerI(CCCrossPartyRegRs.EXT_FIELD_NUMBER, CCCrossPartyRegHandler.class);
            registerI(CCGetCrossPartyMemberRs.EXT_FIELD_NUMBER, CCGetCrossPartyMemberHandler.class);
            registerI(CCGetCrossPartyRs.EXT_FIELD_NUMBER, CCGetCrossPartyHandler.class);
            registerI(CCGetCPFormRs.EXT_FIELD_NUMBER, CCGetCPFormHandler.class);
            registerI(CCSetCPFormRs.EXT_FIELD_NUMBER, CCSetCPFormHandler.class);
            registerI(CCGetCPSituationRs.EXT_FIELD_NUMBER, CCGetCPSituationHandler.class);
            registerI(CCGetCPOurServerSituationRs.EXT_FIELD_NUMBER, CCGetCPOurServerSituationHandler.class);
            registerI(CCGetCPReportRs.EXT_FIELD_NUMBER, CCGetCPReportHandler.class);
            registerI(CCGetCPRankRs.EXT_FIELD_NUMBER, CCGetCPRankHandler.class);
            registerI(CCReceiveCPRewardRs.EXT_FIELD_NUMBER, CCReceiveCPRewardHandler.class);
            registerI(CCGetCPMyRegInfoRs.EXT_FIELD_NUMBER, CCGetCPMyRegInfoHandler.class);
            registerI(CCSynCPSituationRq.EXT_FIELD_NUMBER, CCSynCPSituationHandler.class);
            registerI(CCGetCPShopRs.EXT_FIELD_NUMBER, CCGetCPShopHandler.class);
            registerI(CCExchangeCPShopRs.EXT_FIELD_NUMBER, CCExchangeCPShopHandler.class);
            registerI(CCGetCPTrendRs.EXT_FIELD_NUMBER, CCGetCPTrendHandler.class);
            registerI(CCSynCrossPartyStateRq.EXT_FIELD_NUMBER, CCSynCrossPartyStateHandler.class);
            registerI(CCCanQuitPartyRs.EXT_FIELD_NUMBER, CCCanQuitPartyHandler.class);

            //crossmin 组队副本
            registerI(CrossMinPb.CrossMinGameServerRegRs.EXT_FIELD_NUMBER, CrossMinGameServerRegRsHandler.class);
            registerI(CrossMinPb.CrossMinHeartRs.EXT_FIELD_NUMBER, CrossMinHeartHandler.class);
            registerI(CrossMinPb.CrossNotifyDisMissTeamRq.EXT_FIELD_NUMBER, CrossNotifyDisMissTeamHandler.class);
            registerI(CrossMinPb.CrossSynTeamInfoRq.EXT_FIELD_NUMBER, CrossFindTeamHandler.class);
            registerI(CrossMinPb.CrossSynNotifyKickOutRq.EXT_FIELD_NUMBER, CrossKickTeamHandler.class);
            registerI(CrossMinPb.CrossSynChangeStatusRq.EXT_FIELD_NUMBER, CrossChangeMemberStatusHandler.class);
            registerI(CrossMinPb.CrossSynTeamChatRq.EXT_FIELD_NUMBER, CrossTeamChatHandler.class);
            registerI(CrossMinPb.CrossSynTeamInviteRq.EXT_FIELD_NUMBER, CrossTeamInviteHandler.class);
            registerI(CrossMinPb.CrossSynStageCloseToTeamRq.EXT_FIELD_NUMBER, CrossDisInvalidTeamHandler.class);
            registerI(CrossMinPb.CrossSynTaskRq.EXT_FIELD_NUMBER, CrossSynTaskHandler.class);
            registerI(CrossMinPb.CrossSyncTeamFightBossRq.EXT_FIELD_NUMBER, CrossFightRecordHandler.class);
            registerI(CrossMinPb.CrossWorldChatRq.EXT_FIELD_NUMBER, CrossWorldChatHandler.class);
            registerI(CrossMinPb.CrossFightRs.EXT_FIELD_NUMBER, CrossFightCodeHandler.class);

            //crossmin 攻打跨服军矿
            registerI(CrossMinPb.CrossNpcMine.EXT_FIELD_NUMBER, CrossAttackNpcMineHandler.class);
            registerI(CrossMinPb.CrossMine.EXT_FIELD_NUMBER, CrossAttackMineHandler.class);


        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    // @formatter:on

    /**
     * @param id           接收消息协议编号
     * @param rsCmd        返回消息协议的编号
     * @param handlerClass hanlder的类型 void
     * @throws @Title: registerC
     * @Description: 注册于账号服通信的消息协议与hanlder对应关系
     */
    private void registerC(int id, int rsCmd, Class<? extends ClientHandler> handlerClass) {
        if (handlerClass != null) {
            clientHandlers.put(id, handlerClass);
            rsMsgCmd.put(id, rsCmd);
        }
    }

    /**
     * @param id           接收消息协议编号
     * @param rsCmd        返回消息协议的编号
     * @param handlerClass hanlder的类型 void
     * @throws @Title: registerS
     * @Description: 注册于账号服通信的消息协议与hanlder对应关系
     */
    private void registerS(int id, int rsCmd, Class<? extends ServerHandler> handlerClass) {
        if (handlerClass != null) {
            serverHandlers.put(id, handlerClass);
            rsMsgCmd.put(id, rsCmd);
        }
    }

    /**
     * @param id           消息协议编号
     * @param handlerClass hanlder的类型 void
     * @throws @Title: registerI
     * @Description: 注册跨服服务器通信的消息协议与hanlder对应关系
     */
    private void registerI(int id, Class<? extends InnerHandler> handlerClass) {
        if (handlerClass != null) {
            innerHandlers.put(id, handlerClass);
            // rsMsgCmd.put(id, rsCmd);
        }
    }

    /**
     * @param id 接收消息协议编号
     * @return 消息处理handler
     * @throws InstantiationException
     * @throws IllegalAccessException ClientHandler
     * @throws @Title:                getClientHandler
     * @Description: 根据协议编号 得到对应客户端handler
     */
    public ClientHandler getClientHandler(int id) throws InstantiationException, IllegalAccessException {
        if (!clientHandlers.containsKey(id)) {
            return null;
        } else {
            ClientHandler handler = clientHandlers.get(id).newInstance();
            handler.setRsMsgCmd(rsMsgCmd.get(id));
            return handler;
        }
    }

    /**
     * @param id 协议编号
     * @return 消息处理handler
     * @throws InstantiationException
     * @throws IllegalAccessException ServerHandler
     * @throws @Title:                getServerHandler
     * @Description: 根据协议编号 得到对应账号服处理handler
     */
    public ServerHandler getServerHandler(int id) throws InstantiationException, IllegalAccessException {
        if (!serverHandlers.containsKey(id)) {
            return null;
        } else {
            ServerHandler handler = serverHandlers.get(id).newInstance();
            handler.setRsMsgCmd(rsMsgCmd.get(id));
            return handler;
        }
    }

    /**
     * @param id 协议编号
     * @return 消息处理handler
     * @throws InstantiationException
     * @throws IllegalAccessException InnerHandler
     * @throws @Title:                getInnerHandler
     * @Description: 根据协议编号 得到对应跨服消息处理的handler
     */
    public InnerHandler getInnerHandler(int id) throws InstantiationException, IllegalAccessException {
        if (!innerHandlers.containsKey(id)) {
            return null;
        } else {
            InnerHandler handler = innerHandlers.get(id).newInstance();
            return handler;
        }
    }

}
