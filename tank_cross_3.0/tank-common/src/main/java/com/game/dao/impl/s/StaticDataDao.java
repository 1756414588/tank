/**
 * @Title: StaticDataDao.java @Package com.game.dao.impl.s @Description: TODO
 * @author ZhangJun
 * @date 2015年8月13日 下午4:44:34
 * @version V1.0
 */
package com.game.dao.impl.s;

import com.game.dao.BaseDao;
import com.game.domain.s.*;
import com.game.domain.s.tactics.*;

import java.util.List;
import java.util.Map;

/**
 * @ClassName: StaticDataDao @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月13日 下午4:44:34
 */
public class StaticDataDao extends BaseDao {

    /** 作战研究院物品信息 */
    public List<StaticLaboratoryItem> selectLaboratoryItem() {
        return getSqlSession().selectList("StaticDao.selectLaboratoryItem");
    }

    /** 作战研究院物品信息 */
    public List<StaticLaboratoryMilitary> selectLaboratoryMilitary() {
        return getSqlSession().selectList("StaticDao.selectLaboratoryMilitary");
    }

    /** 作战研究院建筑改进表 */
    public List<StaticLaboratoryProgress> selectLaboratoryProgress() {
        return getSqlSession().selectList("StaticDao.selectLaboratoryProgress");
    }

    /** 作战研究院建筑改进表 */
    public List<StaticLaboratoryResearch> selectLaboratoryResearch() {
        return getSqlSession().selectList("StaticDao.selectLaboratoryResearch");
    }

    /** 作战研究院科技信息 */
    public List<StaticLaboratoryTech> selecLtaboratoryTech() {
        return getSqlSession().selectList("StaticDao.selecLtaboratoryTech");
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
     * 查询军衔信息
     *
     * @return
     */
    public Map<Integer, StaticMilitaryRank> selectMilitaryRank() {
        return getSqlSession().selectMap("StaticDao.selectMilitaryRank", "id");
    }

    public Map<Integer, StaticLordEquip> selectLordEquip() {
        return getSqlSession().selectMap("StaticDao.selectLordEquip", "id");
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

    public List<StaticMineForm> selectMineForm() {
        return getSqlSession().selectList("StaticDao.selectMineForm");
    }

    public Map<Integer, StaticLiveTask> selectLiveTaskMap() {
        return getSqlSession().selectMap("StaticDao.selectPartyLiveTask", "taskId");
    }

    public List<StaticTask> selectTask() {
        return getSqlSession().selectList("StaticDao.selectTask");
    }

    public List<StaticTaskLive> selectLiveTask() {
        return getSqlSession().selectList("StaticDao.selectLiveTask");
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

    public Map<Integer, StaticEnergyStone> selectEnergyStoneMap() {
        return getSqlSession().selectMap("StaticDao.selectEnergyStoneMap", "stoneId");
    }

    public Map<Integer, StaticEnergyHiddenAttr> selectEnergyHiddenAttrMap() {
        return getSqlSession().selectMap("StaticDao.selectEnergyHiddenAttrMap", "attributeID");
    }

    public Map<Integer, StaticAltarBoss> selectAltarBossMap() {
        return getSqlSession().selectMap("StaticDao.selectAltarBossMap", "lv");
    }

    public Map<Integer, StaticCrossShop> selectCrossShopMap() {
        return getSqlSession().selectMap("StaticDao.selectCrossShopMap", "goodID");
    }

    public Map<Integer, StaticSeverWarBetting> selectSeverWarBetting() {
        return getSqlSession().selectMap("StaticDao.selectSeverWarBetting", "bettingid");
    }

    public Map<Integer, StaticServerPartyWining> selectServerPartyWining() {
        return getSqlSession().selectMap("StaticDao.selectServerPartyWining", "time");
    }

    public List<StaticEquipBonusAttribute> selectEquipBonusAttribute() {
        return getSqlSession().selectList("StaticDao.selectEquipBonusAttribute");
    }

    public Map<Integer, StaticMedal> selectMedalMap() {
        return getSqlSession().selectMap("StaticDao.selectMedal", "medalId");
    }

    public List<StaticMedalUp> selectMedalUp() {
        return getSqlSession().selectList("StaticDao.selectMedalUp");
    }

    public List<StaticMedalRefit> selectMedalRefit() {
        return getSqlSession().selectList("StaticDao.selectMedalRefit");
    }

    public List<StaticMedalBouns> selectMedalBounsList() {
        return getSqlSession().selectList("StaticDao.selectMedalBouns");
    }

    public Map<Integer, StaticSystem> selectSystemMap() {
        return getSqlSession().selectMap("StaticDao.selectSystemMap", "id");
    }

    public List<StaticHeroAwakenSkill> selectStaticHeroAwakenSkillList() {
        return getSqlSession().selectList("StaticDao.selectStaticHeroAwakenSkill");
    }

    public Map<Integer, StaticEquipUpStar> selectStaticEquipUpStar() {
        return getSqlSession().selectMap("StaticDao.selectStaticEquipUpStar", "beforeStarLv");
    }

    /** @return 返回军备技能表 */
    public Map<Integer, StaticLordEquipSkill> selectLordEquipSkill() {
        return getSqlSession().selectMap("StaticDao.selectStaticLordEquipSkill", "id");
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


    public List<StaticCoreExp> selectStaticCoreExp() {
        return this.getSqlSession().selectList("StaticDao.selectStaticCoreExp");
    }

    public Map<Integer, StaticCoreAward> selectStaticCoreAward() {
        return this.getSqlSession().selectMap("StaticDao.selectStaticCoreAward", "level");
    }


    public Map<Integer, StaticMine> selectCrossMineSenior() {
        return getSqlSession().selectMap("StaticDao.selectCrossMineSenior", "pos");
    }
}
