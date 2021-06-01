/**
 * @Title: StaticDataDao.java
 * @Package com.game.dao.impl.s
 * @Description:
 * @author ZhangJun
 * @date 2015年8月13日 下午4:44:34
 * @version V1.0
 */
package com.game.dao.impl.s;

import com.game.dao.BaseDao;
import com.game.domain.s.*;
import com.game.domain.s.friend.StaticFriend;
import com.game.domain.s.friend.StaticFriendGift;
import com.game.domain.s.tactics.*;

import java.util.List;
import java.util.Map;

/**
 * @author ZhangJun
 * @ClassName: StaticDataDao
 * @Description:游戏配置数据
 * @date 2015年8月13日 下午4:44:34
 */
public class StaticDataDao extends BaseDao {

    /**
     * 抢红包活动
     *
     * @return
     */
    public List<StaticActRedBag> selectStaticActRedBag() {
        return getSqlSession().selectList("StaticDao.selectStaticActRedBag");
    }

    /**
     * 闪击行动活动
     *
     * @return
     */
    public List<StaticActStroke> selectStaticActStroke() {
        return getSqlSession().selectList("StaticDao.selectStaticActStroke");
    }

    /**
     * 大咖带队
     *
     * @return
     */
    public List<StaticActVipCount> selectStaticActVipCount() {
        return getSqlSession().selectList("StaticDao.selectStaticActVipCount");
    }

    /**
     * 大富翁活动配置
     *
     * @return
     */
    public Map<Integer, StaticActMonopoly> selectStaticActMonopoly() {
        return getSqlSession().selectMap("StaticDao.selectStaticActMonopoly", "id");
    }

    /**
     * 大富翁活动事件列表
     *
     * @return
     */
    public Map<Integer, StaticActMonopolyEvt> selectStaticActMonopolyEvt() {
        return getSqlSession().selectMap("StaticDao.selectStaticActMonopolyEvt", "id");
    }

    /**
     * 大富翁购买事件明细
     *
     * @return
     */
    public Map<Integer, StaticActMonopolyEvtBuy> selectStaticActMonopolyEvtBuy() {
        return getSqlSession().selectMap("StaticDao.selectStaticActMonopolyEvtBuy", "id");
    }

    /**
     * 大富翁对话事件明细
     *
     * @return
     */
    public Map<Integer, StaticActMonopolyEvtDlg> selectStaticActMonopolyEvtDlg() {
        return getSqlSession().selectMap("StaticDao.selectStaticActMonopolyEvtDlg", "id");
    }

    /**
     * 查询兵种攻击特效
     *
     * @return
     */
    public Map<Integer, StaticAttackEffect> selectStaticAttackEffect() {
        return getSqlSession().selectMap("StaticDao.selectStaticAttackEffect", "id");
    }

    /**
     * 查询秘密武器技能信息
     *
     * @return
     */
    public Map<Integer, StaticSecretWeaponSkill> selectSecretWeaponSkill() {
        return getSqlSession().selectMap("StaticDao.selectSecretWeaponSkill", "sid");
    }

    /**
     * 查询秘密武器信息
     *
     * @return
     */
    public Map<Integer, StaticSecretWeapon> selectSecretWeapon() {
        return getSqlSession().selectMap("StaticDao.selectSecretWeapon", "id");
    }

    /**
     * 查询荣誉勋章活动商城
     *
     * @return
     */
    public Map<Integer, StaticActMedalofhonorRule> selectActMedalofhonorRule() {
        return getSqlSession().selectMap("StaticDao.selectActMedalofhonorRule", "id");
    }

    /**
     * 查询荣誉勋章索敌配置
     *
     * @return
     */
    public StaticActMedalofhonorExplore selectActMedalofhonorExplore() {
        return getSqlSession().selectOne("StaticDao.selectActMedalofhonorExplore");
    }

    /**
     * 查询勋章荣誉活动配置
     *
     * @return
     */
    public Map<Integer, StaticActMedalofhonor> selectActMedalOfhonor() {
        return getSqlSession().selectMap("StaticDao.selectActMedalOfhonor", "id");
    }

    /**
     * 查询回归活动buff信息
     *
     * @return
     */
    public Map<Integer, StaticBackBuff> selectBackBuffMap() {
        return getSqlSession().selectMap("StaticDao.selectBackBuff", "keyId");
    }

    /**
     * 查询回归活动返利信息
     *
     * @return
     */
    public Map<Integer, StaticBackMoney> selectBackMoneyMap() {
        return getSqlSession().selectMap("StaticDao.selectBackMoney", "keyId");
    }

    /**
     * 查询回归活动礼包信息
     *
     * @return
     */
    public Map<Integer, StaticBackOne> selectBackOneMap() {
        return getSqlSession().selectMap("StaticDao.selectBackOne", "keyId");
    }

    /**
     * 查询淬炼大师活动，抽奖信息
     *
     * @return
     */
    public Map<Integer, StaticActPartMasterLottery> selectStaticActPartMasterLottery() {
        return getSqlSession().selectMap("StaticDao.selectActPartMasterLottery", "id");
    }

    /**
     * 查询淬炼大师活动信息
     *
     * @return
     */
    public Map<Integer, StaticActPartMaster> selectStaticActPartMaster() {
        return getSqlSession().selectMap("StaticDao.selectActPartMaster", "id");
    }

    /**
     * 查询军衔信息
     *
     * @return
     */
    public Map<Integer, StaticMilitaryRank> selectMilitaryRank() {
        return getSqlSession().selectMap("StaticDao.selectMilitaryRank", "id");
    }

    public Map<Integer, StaticActPartCrit> selectActPartCrit() {
        return getSqlSession().selectMap("StaticDao.selectActPartCrit", "id");
    }

    public Map<Integer, StaticFormula> selectFormula() {
        return getSqlSession().selectMap("StaticDao.selectFormula", "id");
    }

    public Map<Integer, StaticBuilding> selectBuilding() {
        return getSqlSession().selectMap("StaticDao.selectBuilding", "buildingId");
    }

    public List<StaticBuildingLv> selectBuildingLv() {
        return getSqlSession().selectList("StaticDao.selectBuildingLv");
    }

    public List<StaticIniName> selectName() {
        return getSqlSession().selectList("StaticDao.selectName");
    }

    public StaticIniLord selectLord() {
        return getSqlSession().selectOne("StaticDao.selectLord");
    }

    public Map<Integer, StaticLordLv> selectLordLv() {
        return getSqlSession().selectMap("StaticDao.selectLordLv", "lordLv");
    }

    public Map<Integer, StaticLordCommand> selectLordCommand() {
        return getSqlSession().selectMap("StaticDao.selectLordCommand", "commandLv");
    }

    public List<StaticLordPros> selectLordPros() {
        return getSqlSession().selectList("StaticDao.selectLordPros");
    }

    public Map<Integer, StaticLordRank> selectLordRank() {
        return getSqlSession().selectMap("StaticDao.selectLordRank", "rankId");
    }

    public Map<Integer, StaticTank> selectTank() {
        return getSqlSession().selectMap("StaticDao.selectTank", "tankId");
    }

    public Map<Integer, StaticSkill> selectSkill() {
        return getSqlSession().selectMap("StaticDao.selectSkill", "skillId");
    }

    public Map<Integer, StaticProp> selectProp() {
        return getSqlSession().selectMap("StaticDao.selectProp", "propId");
    }

    public Map<Integer, StaticEquip> selectEquip() {
        return getSqlSession().selectMap("StaticDao.selectEquip", "equipId");
    }

    public Map<Integer, StaticLordEquip> selectLordEquip() {
        return getSqlSession().selectMap("StaticDao.selectLordEquip", "id");
    }

    public Map<Integer, StaticTechnical> selectTechnical() {
        return getSqlSession().selectMap("StaticDao.selectTechnical", "id");
    }

    public Map<Integer, StaticLordEquipMaterial> selectLordEquipMaterial() {
        return getSqlSession().selectMap("StaticDao.selectLordEquipMaterial", "id");
    }

    public List<StaticEquipBonusAttribute> selectEquipBonusAttribute() {
        return getSqlSession().selectList("StaticDao.selectEquipBonusAttribute");
    }

    public List<StaticEquipLv> selectEquipLv() {
        return getSqlSession().selectList("StaticDao.selectEquipLv");
    }

    public Map<Integer, StaticPart> selectPart() {
        return getSqlSession().selectMap("StaticDao.selectPart", "partId");
    }

    public List<StaticPartUp> selectPartUp() {
        return getSqlSession().selectList("StaticDao.selectPartUp");
    }

    public List<StaticPartRefit> selectPartRefit() {
        return getSqlSession().selectList("StaticDao.selectPartRefit");
    }

    public Map<Integer, StaticPartSmelting> selectPartSmelting() {
        return getSqlSession().selectMap("StaticDao.selectPartSmelting", "kind");
    }

    public List<StaticCombat> selectCombat() {
        return getSqlSession().selectList("StaticDao.selectCombat");
    }

    public Map<Integer, StaticSection> selectSection() {
        return getSqlSession().selectMap("StaticDao.selectSection", "sectionId");
    }

    public Map<Integer, StaticRefine> selectRefineMap() {
        return getSqlSession().selectMap("StaticDao.selectRefine", "refineId");
    }

    public List<StaticRefineLv> selectRefineLv() {
        return getSqlSession().selectList("StaticDao.selectRefineLv");
    }

    public Map<Integer, StaticAwards> selectAwardsMap() {
        return getSqlSession().selectMap("StaticDao.selectAwards", "awardId");
    }

    public List<StaticCost> selectCost() {
        return getSqlSession().selectList("StaticDao.selectCost");
    }

    public Map<Integer, StaticHero> selectHeroMap() {
        return getSqlSession().selectMap("StaticDao.selectHero", "heroId");
    }

    public List<StaticExplore> selectExplore() {
        return getSqlSession().selectList("StaticDao.selectExplore");
    }

    public Map<Integer, StaticBuff> selectBuff() {
        return getSqlSession().selectMap("StaticDao.selectBuff", "buffId");
    }

    public List<StaticArenaAward> selectArenaAward() {
        return getSqlSession().selectList("StaticDao.selectArenaAward");
    }

    public List<StaticPartyBuildLevel> selectPartyBuildLevel() {
        return getSqlSession().selectList("StaticDao.selectPartyBuildLevel");
    }

    public List<StaticPartyContribute> selectPartyContribute() {
        return getSqlSession().selectList("StaticDao.selectPartyContribute");
    }

    public Map<Integer, StaticPartyLively> selectPartyLivelyMap() {
        return getSqlSession().selectMap("StaticDao.selectPartyLively", "livelyLv");
    }

    public Map<Integer, StaticPartyProp> selectPartyProp() {
        return getSqlSession().selectMap("StaticDao.selectPartyProp", "keyId");
    }

    public List<StaticPartyScience> selectPartyScience() {
        return getSqlSession().selectList("StaticDao.selectPartyScience");
    }

    public Map<Integer, StaticPartyWeal> selectPartyWealMap() {
        return getSqlSession().selectMap("StaticDao.selectPartyWeal", "wealLv");
    }

    public Map<Integer, StaticScout> selectScout() {
        return getSqlSession().selectMap("StaticDao.selectScout", "lv");
    }

    public Map<Integer, StaticMine> selectMine() {
        return getSqlSession().selectMap("StaticDao.selectMine", "pos");
    }

    public List<StaticMineLv> selectMineLv() {
        return getSqlSession().selectList("StaticDao.selectMineLv");
    }

    public List<StaticWorldMine> selectWorldMineLv() {
        return getSqlSession().selectList("StaticDao.selectWorldMineLv");
    }

    public List<StaticWorldMineSpeed> selectStaticWorldMineSpeed() {
        return getSqlSession().selectList("StaticDao.selectStaticWorldMineSpeed");
    }

    public List<StaticMineForm> selectMineForm() {
        return getSqlSession().selectList("StaticDao.selectMineForm");
    }

    public Map<Integer, StaticMineQuality> selectMineQulity() {
        return getSqlSession().selectMap("StaticDao.selectMineQuality", "id");
    }

    public Map<Integer, StaticMineQuality> selectMineQulity1() {
        return getSqlSession().selectMap("StaticDao.selectMineQuality", "id");
    }

    public Map<Integer, StaticLiveTask> selectLiveTaskMap() {
        return getSqlSession().selectMap("StaticDao.selectPartyLiveTask", "taskId");
    }

    public List<StaticTask> selectTaskActivity() {
        return getSqlSession().selectList("StaticDao.selectTaskActivity");
    }

    public List<StaticTask> selectTask() {
        return getSqlSession().selectList("StaticDao.selectTask");
    }

    public List<StaticTaskLive> selectLiveTask() {
        return getSqlSession().selectList("StaticDao.selectLiveTask");
    }

    public List<StaticTaskLiveActivity> selectLiveTaskActivity() {
        return getSqlSession().selectList("StaticDao.selectLiveTaskActivity");
    }

    public Map<Integer, StaticPartyTrend> selectTrend() {
        return getSqlSession().selectMap("StaticDao.selectTrend", "trendId");
    }

    public List<StaticSlot> selectSlot() {
        return getSqlSession().selectList("StaticDao.selectSlot");
    }

    public Map<Integer, StaticMail> selectMail() {
        return getSqlSession().selectMap("StaticDao.selectMail", "moldId");
    }

    public Map<Integer, StaticPartyCombat> selectPartyCombat() {
        return getSqlSession().selectMap("StaticDao.selectPartyCombat", "combatId");
    }

    public Map<Integer, StaticSign> selectSign() {
        return getSqlSession().selectMap("StaticDao.selectSign", "signId");
    }

    public Map<Integer, StaticMonthSign> selectMonthSign() {
        return getSqlSession().selectMap("StaticDao.selectMonthSign", "id");
    }

    public List<StaticVip> selectVip() {
        return getSqlSession().selectList("StaticDao.selectVip");
    }

    public Map<Integer, StaticParty> selectParty() {
        return getSqlSession().selectMap("StaticDao.selectParty", "partyLv");
    }

    public List<StaticActAward> selectActAward() {
        return getSqlSession().selectList("StaticDao.selectActAward");
    }

    public Map<Integer, StaticActMecha> selectActMecha() {
        return getSqlSession().selectMap("StaticDao.selectActMecha", "mechaId");
    }

    public Map<Integer, StaticActQuota> selectActQuota() {
        return getSqlSession().selectMap("StaticDao.selectActQuota", "quotaId");
    }

    public Map<Integer, StaticActRebate> selectActRebate() {
        return getSqlSession().selectMap("StaticDao.selectActRebate", "rebateId");
    }

    public List<StaticPay> selectPay() {
        return getSqlSession().selectList("StaticDao.selectPay");
    }

    public List<StaticPay> selectPayIos() {
        return getSqlSession().selectList("StaticDao.selectPayIos");
    }

    public Map<Integer, StaticActFortune> selectActFortune() {
        return getSqlSession().selectMap("StaticDao.selectActFortune", "fortuneId");
    }

    public List<StaticActRank> selectActRankList() {
        return getSqlSession().selectList("StaticDao.selectActRank");
    }

    public List<StaticSignLogin> selectSignLogin() {
        return getSqlSession().selectList("StaticDao.selectSignLogin");
    }

    public Map<Integer, StaticActProfoto> selectActProfoto() {
        return getSqlSession().selectMap("StaticDao.selectActProfoto", "activityId");
    }

    public List<StaticActRaffle> selectActRaffle() {
        return getSqlSession().selectList("StaticDao.selectActRaffle");
    }

    public List<StaticActCourse> selectActCourse() {
        return getSqlSession().selectList("StaticDao.selectActCourse");
    }

    public Map<Integer, StaticActivity> selectStaticActivity() {
        return getSqlSession().selectMap("StaticDao.selectStaticActivity", "activityId");
    }

    public List<StaticActivityPlan> selectStaticActivityPlan() {
        return getSqlSession().selectList("StaticDao.selectStaticActivityPlan");
    }

    public Map<Integer, StaticActTech> selectActTech() {
        return getSqlSession().selectMap("StaticDao.selectActTech", "techId");
    }

    public Map<Integer, StaticWarAward> selectWarAward() {
        return getSqlSession().selectMap("StaticDao.selectWarAward", "rank");
    }

    public Map<Integer, StaticActGeneral> selectActGeneral() {
        return getSqlSession().selectMap("StaticDao.selectActGeneral", "generalId");
    }

    public Map<Integer, StaticActEverydayPay> selectActEveryDayPay() {
        return getSqlSession().selectMap("StaticDao.selectActEveryDayPay", "dayiy");
    }

    public Map<Integer, StaticActDestory> selectActDestory() {
        return getSqlSession().selectMap("StaticDao.selectActDestory", "tankId");
    }

    public Map<Integer, StaticStaffingLv> selectStaffingLv() {
        return getSqlSession().selectMap("StaticDao.selectStaffingLv", "staffingLv");
    }

    public Map<Integer, StaticStaffing> selectStaffing() {
        return getSqlSession().selectMap("StaticDao.selectStaffing", "staffingId");
    }

    public Map<Integer, StaticStaffingWorld> selectStaffingWorld() {
        return getSqlSession().selectMap("StaticDao.selectStaffingWorld", "worldLv");
    }

    public Map<Integer, StaticMine> selectMineSenior() {
        return getSqlSession().selectMap("StaticDao.selectMineSenior", "pos");
    }

    public Map<Integer, StaticActVacationland> selectActVacationland() {
        return getSqlSession().selectMap("StaticDao.selectActVacationland", "landId");
    }

    public List<StaticActExchange> selectActExchange() {
        return getSqlSession().selectList("StaticDao.selectActExchange");
    }

    public List<StaticActPartResolve> selectActPartResolve() {
        return getSqlSession().selectList("StaticDao.selectActPartResolve");
    }

    public List<StaticActGamble> selectActGamble() {
        return getSqlSession().selectList("StaticDao.selectActGamble");
    }

    public List<StaticFunctionPlan> selectFunctionPlan() {
        return getSqlSession().selectList("StaticDao.selectFunctionPlan");
    }

    public List<StaticMailPlat> selectStaticMailPlat() {
        return getSqlSession().selectList("StaticDao.selectMailPlat");
    }

    public List<StaticActionMsg> selectStaticActionMsg() {
        return getSqlSession().selectList("StaticDao.selectActionMsg");
    }

    public Map<Integer, StaticFortressSufferJifen> selectFortressSufferJifenMap() {
        return getSqlSession().selectMap("selectFortressSufferJifenMap", "tankId");
    }

    public List<StaticFortressAttr> selectFortressAttr() {
        return getSqlSession().selectList("selectFortressAttr");
    }

    public Map<Integer, StaticFortressJob> selectFortressJob() {
        return getSqlSession().selectMap("selectFortressJob", "id");
    }

    public List<StaticMilitary> selectStaticMilitary() {
        return getSqlSession().selectList("StaticDao.selectStaticMilitary");
    }

    public List<StaticMilitaryDevelopTree> selectStaticMilitaryDevelopTree() {
        return getSqlSession().selectList("StaticDao.selectStaticMilitaryDevelopTree");
    }

    public Map<Integer, StaticMilitaryMaterial> selectStaticMilitaryMaterial() {
        return getSqlSession().selectMap("selectStaticMilitaryMaterial", "id");
    }

    public StaticMilitaryBless selectStaticMilitaryBless() {
        return getSqlSession().selectOne("selectStaticMilitaryBless");
    }

    public List<StaticPendant> selectStaticPendant() {
        return getSqlSession().selectList("StaticDao.selectStaticPendant");
    }

    public List<StaticPortrait> selectStaticPortrait() {
        return getSqlSession().selectList("StaticDao.selectStaticPortrait");
    }

    public Map<Integer, StaticEnergyStone> selectEnergyStoneMap() {
        return getSqlSession().selectMap("StaticDao.selectEnergyStoneMap", "stoneId");
    }

    public Map<Integer, StaticEnergyHiddenAttr> selectEnergyHiddenAttrMap() {
        return getSqlSession().selectMap("StaticDao.selectEnergyHiddenAttrMap", "attributeID");
    }

    public Map<Integer, StaticAltarBoss> selectAltarBossMap() {
        return getSqlSession().selectMap("StaticDao.selectAltarBossMap", "lv");
    }

    public List<StaticTreasureShop> selectTreasureShop() {
        return getSqlSession().selectList("StaticDao.selectTreasureShop");
    }

    public Map<Integer, StaticVipShop> selectVipShopMap() {
        return getSqlSession().selectMap("StaticDao.selectVipShop", "gid");
    }

    public Map<Integer, StaticWorldShop> selectWorldShopMap() {
        return getSqlSession().selectMap("StaticDao.selectWorldShopMap", "gid");
    }

    public Map<Integer, StaticDrillShop> selectDrillShopMap() {
        return getSqlSession().selectMap("StaticDao.selectDrillShopMap", "goodID");
    }

    public List<StaticDrillBuff> selectDrillBuffList() {
        return getSqlSession().selectList("StaticDao.selectDrillBuffList");
    }

    public Map<Integer, StaticDrillFeat> selectDrillFeatMap() {
        return getSqlSession().selectMap("StaticDao.selectDrillFeatMap", "tankId");
    }

    public Map<Integer, StaticPartQualityUp> selectPartQualityUpMap() {
        return getSqlSession().selectMap("StaticDao.selectPartQualityUpMap", "partId");
    }

    public List<StaticActEquate> selectActEquateList() {
        return getSqlSession().selectList("StaticDao.selectActEquateList");
    }

    public Map<Integer, StaticSystem> selectSystemMap() {
        return getSqlSession().selectMap("StaticDao.selectSystemMap", "id");
    }

    public Map<Integer, StaticRebelAttr> selectRebelAttrMap() {
        return getSqlSession().selectMap("StaticDao.selectRebelAttrMap", "keyId");
    }

    public List<StaticRebelHero> selectRebelHeroList() {
        return getSqlSession().selectList("StaticDao.selectRebelHeroList");
    }

    public Map<Integer, StaticRebelTeam> selectRebelTeamMap() {
        return getSqlSession().selectMap("StaticDao.selectRebelTeamMap", "rebelId");
    }

    public List<StaticActivityTime> selectActivityTimeList() {
        return getSqlSession().selectList("StaticDao.selectActivityTimeList");
    }

    public List<StaticActivityEffect> selectActivityEffectList() {
        return getSqlSession().selectList("StaticDao.selectActivityEffectList");
    }

    public Map<Integer, StaticActivityProp> selectActivityPropMap() {
        return getSqlSession().selectMap("StaticDao.selectActivityPropMap", "id");
    }

    public Map<Integer, StaticCharacterChange> selectCharacterChangeMap() {
        return getSqlSession().selectMap("StaticDao.selectCharacterChangeMap", "id");
    }

    public Map<Integer, StaticCrossShop> selectCrossShopMap() {
        return getSqlSession().selectMap("StaticDao.selectCrossShopMap", "goodID");
    }

    public Map<Integer, StaticCrossTrend> selectCrossTrendMap() {
        return getSqlSession().selectMap("StaticDao.selectCrossTrendMap", "trendId");
    }

    public Map<Integer, StaticSeverWarBetting> selectSeverWarBetting() {
        return getSqlSession().selectMap("StaticDao.selectSeverWarBetting", "bettingid");
    }

    public Map<Integer, StaticActivityM1a2> selectActivityM1a2Map() {
        return getSqlSession().selectMap("StaticDao.selectActivityM1a2", "id");
    }

    public Map<Integer, StaticActivityFlower> selectActivityFlowerMap() {
        return getSqlSession().selectMap("StaticDao.staticActivityFlower", "id");
    }

    public Map<Integer, StaticMedal> selectMedalMap() {
        return getSqlSession().selectMap("StaticDao.selectMedal", "medalId");
    }

    public List<StaticMedalBouns> selectMedalBounsList() {
        return getSqlSession().selectList("StaticDao.selectMedalBouns");
    }

    public List<StaticMedalUp> selectMedalUp() {
        return getSqlSession().selectList("StaticDao.selectMedalUp");
    }

    public List<StaticMedalRefit> selectMedalRefit() {
        return getSqlSession().selectList("StaticDao.selectMedalRefit");
    }

    public List<StaticActPayRebate> selectActPayRebateList() {
        return getSqlSession().selectList("StaticDao.selectActPayRebate");
    }

    public List<StaticActPirate> selectActPirateList() {
        return getSqlSession().selectList("StaticDao.selectActPirate");
    }

    public List<StaticActivityChange> selectActivityChange() {
        return getSqlSession().selectList("StaticDao.selectActivityChange");
    }

    public StaticActBoss selectActBoss() {
        return getSqlSession().selectOne("StaticDao.selectActBoss");
    }

    public Map<Integer, StaticActHilarityPray> selectActHilarityPrayMap() {
        return getSqlSession().selectMap("StaticDao.selectActHilarityPray", "id");
    }

    public Map<Integer, StaticFameLv> selectStaticFameLvMap() {
        return getSqlSession().selectMap("StaticDao.selectStaticFameLv", "fameLv");
    }

    public Map<Integer, StaticActWorshipGod> selectActWorshipGodMap() {
        return getSqlSession().selectMap("StaticDao.selectActWorshipGod", "day");
    }

    public List<StaticActWorshipTask> selectActWorshipTaskList() {
        return getSqlSession().selectList("StaticDao.selectActWorshipTask");
    }

    public Map<Integer, StaticActWorshipGodData> selectActWorshipGodDataMap() {
        return getSqlSession().selectMap("StaticDao.selectActWorshipGodData", "count");
    }

    public Map<Integer, StaticActFoison> selectActFoison() {
        return getSqlSession().selectMap("StaticDao.selectActFoison", "awardId");
    }

    public List<StaticActRebelTeam> selectStaticActRebelTeamList() {
        return getSqlSession().selectList("StaticDao.selectStaticActRebelTeam");
    }

    public Map<Integer, StaticActRebelAttr> selectActRebelAttrMap() {
        return getSqlSession().selectMap("StaticDao.selectActRebelAttrMap", "keyId");
    }

    public StaticActRebel selectActRebel() {
        return getSqlSession().selectOne("StaticDao.selectStaticActRebel");
    }

    public List<StaticDay7Act> selectStaticDay7ActList() {
        return getSqlSession().selectList("StaticDao.selectStaticDay7Act");
    }

    public List<StaticHeroAwakenSkill> selectStaticHeroAwakenSkillList() {
        return getSqlSession().selectList("StaticDao.selectStaticHeroAwakenSkill");
    }

    public Map<Integer, StaticActCollegeSubject> selectStaticActCollegeSubjectMap() {
        return getSqlSession().selectMap("StaticDao.selectStaticActCollegeSubject", "id");
    }

    public List<StaticActCollegeEducation> selectStaticActCollegeEducationList() {
        return getSqlSession().selectList("StaticDao.selectStaticActCollegeEducation");
    }

    public Map<Integer, StaticAirship> selectStaticAirshipMap() {
        return getSqlSession().selectMap("StaticDao.selectStaticAirship", "id");
    }

    /**
     * @return 返回军备洗练表
     */
    public Map<Integer, StaticLordEquipChange> selectLordEquipChange() {
        return getSqlSession().selectMap("StaticDao.selectStaticLordEquipChange", "id");
    }

    /**
     * @return 返回军备技能表
     */
    public Map<Integer, StaticLordEquipSkill> selectLordEquipSkill() {
        return getSqlSession().selectMap("StaticDao.selectStaticLordEquipSkill", "id");
    }

    public Map<Integer, StaticEquipUpStar> selectStaticEquipUpStar() {
        return getSqlSession().selectMap("StaticDao.selectStaticEquipUpStar", "beforeStarLv");
    }

    public Map<Integer, StaticHeroPut> selectHeroPutMap() {
        return getSqlSession().selectMap("StaticDao.selectStaticHeroPut", "partId");
    }

    /**
     * @return 返回能量灌注配置表
     */
    public List<StaticActCumulativePay> selectActCumulativePay() {
        return getSqlSession().selectList("StaticDao.selectActCumulativePay");
    }

    /**
     * @return 返回基地皮肤配置表
     */
    public Map<Integer, StaticSkin> selectSkin() {
        return getSqlSession().selectMap("StaticDao.selectSkin", "id");
    }

    /**
     * @return 返回自选豪礼配置表
     */
    public Map<Integer, StaticActChooseGift> selectActChooseGift() {
        return getSqlSession().selectMap("StaticDao.selectActChoosegift", "id");
    }

    /**
     * @return 返回兄弟同心降低战损百分比
     */
    public int selectActBrotherReduceloss() {
        List<Integer> list = getSqlSession().selectList("StaticDao.selectActBrother");
        return list.get(0);
    }

    public List<StaticActBrotherBuff> selectActBrotherBuff() {
        return getSqlSession().selectList("StaticDao.selectActBrotherBuff");
    }

    public List<StaticActBrotherTask> selectActBrotherTask() {
        return getSqlSession().selectList("StaticDao.selectActBrotherTask");
    }

    /**
     * @return 返回超时空财团商品
     */
    public List<StaticActQuinn> selectActQuinn() {
        return getSqlSession().selectList("StaticDao.selectActQuinn");
    }

    /**
     * @return 返回超时空财团金币刷新额外奖励
     */
    public List<StaticActQuinnEasteregg> selectActQuinnEasteregg() {
        return getSqlSession().selectList("StaticDao.selectActQuinnEasteregg");
    }

    /**
     * 下午2:18:01
     */
    public List<StaticActQuinnRefresh> selectActQuinnRefresh() {
        return getSqlSession().selectList("StaticDao.selectActQuinnRefresh");
    }

    /**
     * 作战研究院物品信息
     */
    public List<StaticLaboratoryItem> selectLaboratoryItem() {
        return getSqlSession().selectList("StaticDao.selectLaboratoryItem");
    }

    /**
     * 作战研究院物品信息
     */
    public List<StaticLaboratoryMilitary> selectLaboratoryMilitary() {
        return getSqlSession().selectList("StaticDao.selectLaboratoryMilitary");
    }

    /**
     * 作战研究院建筑改进表
     */
    public List<StaticLaboratoryProgress> selectLaboratoryProgress() {
        return getSqlSession().selectList("StaticDao.selectLaboratoryProgress");
    }

    /**
     * 作战研究院建筑改进表
     */
    public List<StaticLaboratoryResearch> selectLaboratoryResearch() {
        return getSqlSession().selectList("StaticDao.selectLaboratoryResearch");
    }

    /**
     * 作战研究院科技信息
     */
    public List<StaticLaboratoryTech> selecLtaboratoryTech() {
        return getSqlSession().selectList("StaticDao.selecLtaboratoryTech");
    }

    /**
     * 点击宝箱获得奖励
     */
    public List<StaticGifttory> selectGift() {
        return getSqlSession().selectList("StaticDao.selectGift");
    }

    /**
     * 作战研究院谍报机构-地图表
     */
    public List<StaticLaboratoryArea> selectStaticLaboratoryArea() {
        return getSqlSession().selectList("StaticDao.selectStaticLaboratoryArea");
    }

    /**
     * 作战研究院谍报机构-间谍
     */
    public List<StaticLaboratorySpy> selectStaticLaboratorySpy() {
        return getSqlSession().selectList("StaticDao.selectStaticLaboratorySpy");
    }

    /**
     * 作战研究院谍报机构-任务
     */
    public List<StaticLaboratoryTask> selectStaticLaboratoryTask() {
        return getSqlSession().selectList("StaticDao.selectStaticLaboratoryTask");
    }

    /**
     * 红色方案-
     */
    public List<StaticRedPlanPoint> selectStaticRedPlanPoint() {
        return getSqlSession().selectList("StaticDao.selectStaticRedPlanPoint");
    }

    /**
     * 红色方案 -区域
     */
    public List<StaticRedPlanArea> selectStaticRedPlanArea() {
        return getSqlSession().selectList("StaticDao.selectStaticRedPlanArea");
    }

    /**
     * 红色方案 -商店
     */
    public List<StaticRedPlanShop> selectStaticRedPlanShop() {
        return getSqlSession().selectList("StaticDao.selectStaticRedPlanShop");
    }

    /**
     * 红色方案 -购买燃料
     */
    public List<StaticRedPlanFuel> selectStaticRedPlanFuel() {
        return getSqlSession().selectList("StaticDao.selectStaticRedPlanFuel");
    }

    /**
     * 红色方案 -购买燃料
     */
    public List<StaticRedPlanFuelLimit> selectStaticRedPlanFuelLimit() {
        return getSqlSession().selectList("StaticDao.selectStaticRedPlanFuelLimit");
    }

    /**
     * 新手引导奖励
     *
     * @return
     */
    public List<StaticGuideAwards> selectStaticGuideAwards() {
        return getSqlSession().selectList("StaticDao.selectStaticGuideAwards");
    }

    /**
     * 假日碎片
     *
     * @return
     */
    public List<StaticActFestivalPiece> selectStaticActFestivalPiece() {
        return getSqlSession().selectList("StaticDao.selectStaticActFestivalPiece");
    }

    /**
     * 幸运奖池
     *
     * @return
     */
    public List<StaticActLukyDraw> selectStaticActLukyDraw() {
        return getSqlSession().selectList("StaticDao.selectStaticActLukyDraw");
    }

    public List<StaticActConfig> selectStaticActConfig() {
        return getSqlSession().selectList("StaticDao.selectStaticActConfig");
    }

    /**
     * 赏金商店
     *
     * @return
     */
    public List<StaticBountyShop> selectStaticBountyShop() {
        return getSqlSession().selectList("StaticDao.selectStaticBountyShop");
    }

    /**
     * 组队副本BOSS
     *
     * @return
     */
    public List<StaticBountyBoss> selectStaticBountyBoss() {
        return getSqlSession().selectList("StaticDao.selectStaticBountyBoss");
    }

    /**
     * 组队副本关卡
     *
     * @return
     */
    public List<StaticBountyEnemy> selectStaticBountyEnemy() {
        return getSqlSession().selectList("StaticDao.selectStaticBountyEnemy");
    }

    public List<StaticBountyStage> selectStaticBountyStage() {
        return getSqlSession().selectList("StaticDao.selectStaticBountyStage");
    }

    /**
     * 组队副本boss技能
     *
     * @return
     */
    public List<StaticBountySkill> selectStaticBountySkill() {
        return getSqlSession().selectList("StaticDao.selectStaticBountySkill");
    }

    /**
     * 组队副本通缉令
     *
     * @return
     */
    public List<StaticBountyWanted> selectStaticBountyWanted() {
        return getSqlSession().selectList("StaticDao.selectStaticBountyWanted");
    }

    /**
     * 组队副本零散配置
     *
     * @return
     */
    public StaticBountyConfig selectStaticBountyConfig() {
        return getSqlSession().selectOne("StaticDao.selectStaticBountyConfig");
    }

    /**
     * 组队副本零散配置
     */
    public List<StaticTankConvert> selectStaticTankConvert() {
        return getSqlSession().selectList("StaticDao.selectStaticTankConvert");
    }

    public List<StaticActPay> selectStaticActPay() {
        return getSqlSession().selectList("StaticDao.selectStaticActPay");
    }

    public List<StaticActPayNew> selectStaticActPayNew2() {
        return getSqlSession().selectList("StaticDao.selectStaticActPayNew2");
    }

    public List<StaticActTechsell> selectStaticActTechsell() {
        return getSqlSession().selectList("StaticDao.selectStaticActTechsell");
    }

    public List<StaticActBuildsell> selectStaticActBuildsell() {
        return getSqlSession().selectList("StaticDao.selectStaticActBuildsell");
    }

    public List<StaticSeverBoss> selectStaticSeverBoss() {
        return getSqlSession().selectList("StaticDao.selectStaticSeverBoss");
    }

    /**
     * 荣耀生存玩法系统配置
     */
    public Map<Integer, StaticSystem> selectHonourSystemMap() {
        return getSqlSession().selectMap("StaticDao.selectHonourSystemMap", "id");
    }

    /**
     * 荣耀生存玩法BUFF配置
     */
    public List<StaticHonourBuff> selectHonourBuffList() {
        return getSqlSession().selectList("StaticDao.selectHonourBuffList");
    }

    /**
     * 新活跃宝箱配置
     */
    public StaticActiveBoxConfig selectActiveBoxConfig() {
        return getSqlSession().selectOne("StaticDao.selectActiveBoxConfig");
    }

    public List<StaticBouns> selectStaticBouns() {
        return getSqlSession().selectList("StaticDao.selectStaticBouns");
    }

    public List<StaticDaily> selectStaticDaily() {
        return getSqlSession().selectList("StaticDao.selectStaticDaily");
    }

    public List<StaticScoutfreeze> selectStaticScoutfreeze() {
        return getSqlSession().selectList("StaticDao.selectStaticScoutfreeze");
    }

    public List<StaticScoutBonus> selectStaticScoutBonus() {
        return getSqlSession().selectList("StaticDao.selectStaticScoutBonus");
    }

    public List<StaticHonourScoreGold> selectHonourScoreGold() {
        return getSqlSession().selectList("StaticDao.selectHonourScoreGold");
    }

    public List<StaticScoutPic> selectScoutPicList() {
        return getSqlSession().selectList("StaticDao.selectScoutPicList");
    }

    public List<StaticActivityPartyWar> selectActivityPartyWar() {
        return getSqlSession().selectList("StaticDao.selectActivityPartyWar");
    }


    /**
     * 祭坛Boss
     *
     * @return
     */

    public List<StaticAltarBossAward> staticAltarBossAwardList() {
        return getSqlSession().selectList("StaticDao.staticAltarBossAwardList");
    }

    public List<StaticAltarBossContribute> staticAltarBossContributeList() {
        return getSqlSession().selectList("StaticDao.staticAltarBossContributeList");
    }


    public List<StaticAltarBossStar> staticAltarBossStarList() {
        return getSqlSession().selectList("StaticDao.staticAltarBossStarList");
    }


    public List<StaticTactics> selectStaticTactics() {
        return getSqlSession().selectList("StaticDao.selectStaticTactics");
    }

    public List<StaticTacticsTacticsRestrict> selectStaticTacticsTacticsRestrict() {
        return getSqlSession().selectList("StaticDao.selectStaticTacticsTacticsRestrict");
    }

    public List<StaticTacticsTankSuit> selectStaticTacticsTankSuit() {
        return getSqlSession().selectList("StaticDao.selectStaticTacticsTankSuit");
    }

    public List<StaticTacticsUplv> selectStaticTacticsUplv() {
        return getSqlSession().selectList("StaticDao.selectStaticTacticsUplv");
    }

    public List<StaticTacticsBreak> selectStaticTacticsBreak() {
        return getSqlSession().selectList("StaticDao.selectStaticTacticsBreak");
    }

    public List<StaticKingActAward> selectKingActAward() {
        return getSqlSession().selectList("StaticDao.selectKingActAward");
    }

    public List<StaticKingActRatio> selectKingActRatio() {
        return getSqlSession().selectList("StaticDao.selectKingActRatio");
    }

    public List<StaticActKingRank> selectStaticActKingRank() {
        return getSqlSession().selectList("StaticDao.selectStaticActKingRank");
    }

    public Map<Integer, StaticFriend> selectFriendMap() {
        return this.getSqlSession().selectMap("StaticDao.selectFriendMap", "prop");
    }

    public List<StaticFriendGift> selectFriendGiftList() {
        return this.getSqlSession().selectList("StaticDao.selectFriendGiftList");
    }

    public List<StaticCoreExp> selectStaticCoreExp() {
        return this.getSqlSession().selectList("StaticDao.selectStaticCoreExp");
    }

    public Map<Integer, StaticCoreAward> selectStaticCoreAward() {
        return this.getSqlSession().selectMap("StaticDao.selectStaticCoreAward", "level");
    }

    public List<StaticCoreMaterial> selectStaticCoreMaterial() {
        return this.getSqlSession().selectList("StaticDao.selectStaticCoreMaterial");
    }


    public List<StaticMailNew> selectStaticMailNew() {
        return getSqlSession().selectList("StaticDao.selectMailNew");
    }

    public Map<Integer, StaticMine> selectCrossMine() {
        return getSqlSession().selectMap("StaticDao.selectCrossMine", "pos");
    }

    public Map<Integer, StaticPeakLv> selectPeakLv() {
        return getSqlSession().selectMap("StaticDao.selectPeakLv", "id");
    }

    public List<StaticPeakCost> selectPeakCost() {
        return getSqlSession().selectList("StaticDao.selectPeakCost");
    }

    public Map<Integer, StaticPeakSkill> selectPeakSkill() {
        return getSqlSession().selectMap("StaticDao.selectPeakSkill", "id");
    }

}
