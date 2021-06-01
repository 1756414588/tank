package com.game.util;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.game.common.ServerSetting;
import com.game.constant.ActivityConst;
import com.game.constant.AwardFrom;
import com.game.constant.AwardType;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.MedalBouns;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.QueAnswer;
import com.game.server.GameServer;
import org.apache.log4j.Logger;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

/**
 * @author 陈奎
 */

public class LogLordHelper {

    public static Logger GAME_LOGGER = Logger.getLogger("GAME");

    private static String getPoint(int pos) {
        if (pos == 0) {
            return "0,0";
        }
        return (pos % 600) + "," + (pos / 600);
    }

    /**
     * 保护罩buff日志
     *
     * @param from
     * @param player
     * @param state      1 增加 2攻击别人删除 3时间到了删除
     * @param oldEndTime 添加的时间
     * @param endTime    结束时间
     */
    public static void attackFreeBuff(AwardFrom from, Player player, int state, int oldEndTime, long endTime, int pos) {
        try {
            String a = getCommonParams("attackFreeBuff", from, player.account, player.lord);

            String endTimeStr = DateHelper.formatTime(endTime * 1000L, DateHelper.format1);
            String oldEndTimeStr = "";
            if (oldEndTime > 0) {
                oldEndTimeStr = DateHelper.formatTime(oldEndTime * 1000L, DateHelper.format1);
            }

            GAME_LOGGER.error(a + "|" + state + "|" + oldEndTimeStr + "|" + endTimeStr + "|" + getPoint(pos));
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 战术资源增加删除 包含碎片和材料
     *
     * @param from
     * @param player
     * @param state    1增加 2减少
     * @param type     物品类型
     * @param id       物品id
     * @param count    数量
     * @param allCount 改变之后的总数量
     */
    public static void tacticsItemChange(AwardFrom from, Player player, int state, int type, int id, int count, int allCount) {
        String a = getCommonParams("tacticsItem", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + state + "|" + type + "|" + id + "|" + count + "|" + allCount);
    }

    /**
     * 战术增加删除
     *
     * @param from
     * @param player
     * @param state  1增加 2删除 3 更改
     * toString
     * keyId + "|" + tacticsId + "|" + lv + "|" + exp + "|" + use + "|" + state
     *
     *               keyId 每个玩家战术唯一id
     *               tacticsId战术id
     *               lv战术等级
     *               exp战术经验
     *               use 是否使用
     *               state 当前是否突破
     *
     *
     *
     */
    public static void tacticsChange(AwardFrom from, Player player, int state, Tactics tactics) {
        String a = getCommonParams("tactics", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + state + "|" + tactics.toString());
    }


    /**
     * 组队副本挑战
     *
     * @param from
     * @param player
     * @param stageId
     * @param isSucc
     */
    public static void logTeamInstance(AwardFrom from, Player player, String stageId, int isSucc) {
        String a = getCommonParams("TeamInstanceFight", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + stageId + "|" + isSucc);
    }

    /**
     * 问卷调查活动提交记录
     *
     * @param from
     * @param player
     * @param beginTime 活动开启时间，用来区分不同期活动的提交信息
     * @param msg
     */
    public static void logQuestionnaire(AwardFrom from, Player player, int beginTime, List<QueAnswer> msg) {
        if (msg == null || msg.isEmpty()) {
            return;
        }
        StringBuilder info = new StringBuilder();
        info.append("[");
        JSONObject json = new JSONObject();
        for (QueAnswer answer : msg) {
            json.clear();
            json.put("k", answer.getKeyId());
            if (answer.getAddtional() != null && !answer.getAddtional().trim().equals("")) {
                json.put("addtional", answer.getAddtional());
            } else {
                json.put("v", answer.getValue());
            }
            info.append(json.toJSONString() + ",");
        }
        info.deleteCharAt(info.length() - 1);
        info.append("]");
        String a = getCommonParams("questionnaire", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + beginTime + "|" + info);
    }

    /**
     * 侦查日志
     *
     * @param from
     * @param player
     * @param ip
     * @param deviceNo
     * @param time
     * @param pos
     */
    public static void logScoutPos(AwardFrom from, Player player, String ip, String deviceNo, int time, int pos) {
        String a = getCommonParams("scoutPos", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + ip + "|" + deviceNo + "|" + time + "|" + pos);
    }

    /**
     * 作战研究院 兵种深度突破
     *
     * @param from
     * @param player
     */
    public static void logfightLabGraduate(AwardFrom from, Player player, int id, int level) {
        String a = getCommonParams("fightLabGraduate", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + id + "|" + level);
    }


    /**
     * 作战研究院 科技突破
     *
     * @param from
     * @param player
     */
    public static void logfightLabTechUpgradeLevel(AwardFrom from, Player player, int techId, int level) {
        String a = getCommonParams("fightLabTechUpLevel", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + techId + "|" + level);
    }


    /**
     * 作战研究院物建筑激活
     *
     * @param from
     * @param player
     */
    public static void logfightLabArchAct(AwardFrom from, Player player, int archId) {
        String a = getCommonParams("fightLabArchAct", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + archId);
    }


    /**
     * 公共参数组织
     *
     * @param type
     * @param from
     * @param account
     * @param lord
     * @return String
     */
    private static String getCommonParams(String type, AwardFrom from, Account account, Lord lord) {
        int serverId = account.getServerId();
        long lordId = lord.getLordId();
        int vip = lord.getVip();
        int level = lord.getLevel();
        String nick = "\"" + lord.getNick() + "\"";
        String a = type + "|" + from.getCode() + "|" + serverId + "|" + lordId + "|" + nick + "|" + vip + "|"
                + level + "|" + lord.getGold();
        return a;
    }

    /**
     * * 跨服战下注日志
     *
     * @param from
     * @param account
     * @param lord
     * @param serverId 区服
     * @param roleName 角色名
     * @param roleId   角色ID
     * @param group    所在组别
     * @param SArea    所在赛区
     * @param state    下注是否成功
     */
    static public void crossBattle(AwardFrom from, Account account, Lord lord, int serverId, String roleName, Long roleId, String group, String SArea, int state) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("crossBattle", from, account, lord);
        StringBuilder sb = new StringBuilder();
        sb.append(a);
        sb.append("|");
        sb.append(serverId);
        sb.append("|");
        sb.append(roleName);
        sb.append("|");
        sb.append(roleId);
        sb.append("|");
        sb.append(group);
        sb.append("|");
        sb.append(SArea);
        sb.append("|");
        sb.append(state);
        GAME_LOGGER.error(sb.toString());
    }

    /**
     * 作战研究院物品改变
     *
     * @param from
     * @param player
     * @param state  1添加 2扣除
     * @param id
     * @param count
     */
    public static void logFightLabItemChange(AwardFrom from, Player player, int state, int id, int count, int allCount) {
        String a = getCommonParams("fightLabItemChange", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + id + "|" + (state == 2 ? -count : count) + "|" + allCount);
    }

    /**
     * 大富翁(圣诞宝藏)领取免费精力
     *
     * @param from
     * @param player
     * @param beforeEnergy 领取前精力
     * @param addEnergy    增加的精力
     * @param remainEnergy 剩余精力
     */
    public static void logDrawActMonopolyFreeEnergy(AwardFrom from, Player player, int beforeEnergy, int addEnergy, int remainEnergy) {
        String a = getCommonParams("drawActMonopolyFreeEnergy", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + beforeEnergy + "|" + addEnergy + "|" + remainEnergy);
    }

    /**
     * 获得新的攻击特效皮肤
     *
     * @param from
     * @param player
     * @param uid
     */
    public static void logAttackEffectChange(AwardFrom from, Player player, AttackEffect effect, int uid) {
        String a = getCommonParams("getAttackEffect", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + uid + "|" + Arrays.toString(effect.getUnlock().toArray()));
    }

    /**
     * 洗练秘密武器
     *
     * @param from
     * @param player
     * @param lockCount
     * @param costGold
     * @param itemId
     * @param itemCount
     */
    public static void logSecretWeaponStudy(AwardFrom from, Player player, int lockCount, int costGold, int itemId, int itemCount) {
        String a = getCommonParams("studySecretWeapon", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + lockCount + "|" + costGold + "|" + itemId + "|" + itemCount);
    }

    /**
     * 军功发生变化
     *
     * @param from
     * @param account
     * @param lord
     * @param militaryExploit
     * @param change
     * @param mpltLimit       军衔获取上限
     * @param mpltLimitToday  今日获取剩余值
     */
    static public void militaryExploitChange(AwardFrom from, Account account, Lord lord, long militaryExploit, int change, long mpltLimit, int mpltLimitTodayRemain) {
        String a = getCommonParams("militaryExploitChange", from, account, lord);

        GAME_LOGGER.error(a + "|" + militaryExploit + "|" + change + "|" + mpltLimit + "|" + mpltLimitTodayRemain);
    }

    /**
     * 金币
     *
     * @param lord
     * @param cost
     **/
    static public void gold(AwardFrom from, Account account, Lord lord, int gold, int topup) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("gold", from, account, lord) + "|" + gold + "|" + lord.getTopup() + "|" + topup;
        GAME_LOGGER.error(a);
    }

    /**
     * 道具记录
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param propId
     * @param count
     * @param add
     */
    static public void prop(AwardFrom from, Account account, Lord lord, int gold, int propId, int count, int add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("prop", from, account, lord);
        GAME_LOGGER.error(a + "|" + propId + "|" + count + "|" + add);
    }

    /**
     * 装备记录
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param keyId
     * @param equipId
     * @param lv
     * @param upKeyId
     */
    static public void equip(AwardFrom from, Account account, Lord lord, int keyId, int equipId, int lv, int upKeyId) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("equip", from, account, lord);
        GAME_LOGGER.error(a + "|" + keyId + "|" + equipId + "|" + lv + "|" + upKeyId);
    }

    /**
     * 指挥官装备记录
     *
     * @param from
     * @param account
     * @param lord
     * @param keyId
     * @param equipId
     * @param skillList
     */
    static public void lordEquip(AwardFrom from, Account account, Lord lord, int keyId, int equipId) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("lordEquip", from, account, lord);
        GAME_LOGGER.error(a + "|" + keyId + "|" + equipId);
    }

    /**
     * 配件记录
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param keyId
     * @param partId
     * @param lv
     * @param refitLv
     */
    static public void part(AwardFrom from, Account account, Lord lord, Part part) {
        if (account == null || lord == null) {
            return;
        }

        String a = getCommonParams("part", from, account, lord);
        StringBuffer partSmeltData = new StringBuffer();
        for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            partSmeltData.append(entry.getKey() + "." + entry.getValue()[0] + "_");
        }
        if (partSmeltData.length() > 0) {
            partSmeltData.deleteCharAt(partSmeltData.length() - 1);
        }
        GAME_LOGGER.error(a + "|" + part.getKeyId() + "|" + part.getPartId() + "|" + part.getUpLv() + "|" + part.getRefitLv() + "|" + part.getSmeltLv() + "|" + part.getSmeltExp() + "|" + partSmeltData.toString());
    }

    /**
     * 勋章操作
     *
     * @param from
     * @param account
     * @param lord
     * @param medal
     * @param state   0增加 1删除 2改变
     */
    static public void medal(AwardFrom from, Account account, Lord lord, Medal medal, int state) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("medal", from, account, lord);
        GAME_LOGGER.error(a + "|" + medal.getKeyId() + "|" + medal.getMedalId() + "|" + medal.getUpLv() + "|" + medal.getRefitLv() + "|" + state);
    }

    /**
     * 勋章展示
     *
     * @param from
     * @param account
     * @param lord
     * @param medalBouns void
     */
    static public void medalBouns(AwardFrom from, Account account, Lord lord, MedalBouns medalBouns) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("medalBouns", from, account, lord);
        GAME_LOGGER.error(a + "|" + medalBouns.getMedalId() + "|" + medalBouns.getState());
    }

    /**
     * 增加勋章碎片
     *
     * @param from
     * @param account
     * @param lord
     * @param chipId
     * @param count
     * @param add     void
     */
    static public void medalChip(AwardFrom from, Account account, Lord lord, int chipId, int count, int add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("medalChip", from, account, lord);
        GAME_LOGGER.error(a + "|" + chipId + "|" + count + "|" + add);
    }

    /**
     * 配件碎片
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param chipId
     * @param count
     * @param add
     */
    static public void chip(AwardFrom from, Account account, Lord lord, int chipId, int count, int add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("chip", from, account, lord);
        GAME_LOGGER.error(a + "|" + chipId + "|" + count + "|" + add);
    }

    /**
     * 配件材料
     *
     * @param from
     * @param account
     * @param player
     * @param id
     * @param add
     * @param total
     */
    static public void partMaterial(AwardFrom from, Account account, Player player, int id, int add, int total) {
        Lord lord = player.lord;
        if (account == null || lord == null) {
            return;
        }

        String a = getCommonParams("partMaterial", from, account, lord);
        StringBuffer matl = new StringBuffer();
        Iterator<Entry<Integer, Integer>> it = player.partMatrial.entrySet().iterator();
        while (it.hasNext()) {
            Entry<Integer, Integer> entry = it.next();
            matl.append(entry.getKey()).append("_").append(entry.getValue()).append("#");
        }
        if (matl.length() > 0) {
            matl.delete(matl.length() - 1, matl.length());
        }

        GAME_LOGGER.error(a + "|" + id + "|" + total + "|" + add + "|" + matl.toString());
    }

    /**
     * 勋章材料数量改变
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param id
     * @param add     void
     */
    static public void medalMaterial(AwardFrom from, Account account, Lord lord, int gold, int id, int add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("medalMaterial", from, account, lord);
        GAME_LOGGER.error(a + "|" + gold + "|" + lord.getDetergent() + "|" + lord.getGrindstone() + "|" + lord.getPolishingMtr() + "|" + lord.getMaintainOil() + "|" + lord.getGrindTool() + lord.getPrecisionInstrument() + "|" + lord.getMysteryStone() +
                "|" + id + "|" + add + "|" + lord.getCorundumMatrial() + "|" + lord.getInertGas());
    }

    /**
     * 军备材料日志
     *
     * @param from
     * @param account
     * @param lord
     * @param id
     * @param add
     * @param count
     */
    static public void lordEquipMaterial(AwardFrom from, Account account, Lord lord, int id, int add, int count) {
        String a = getCommonParams("lordEquipMaterial", from, account, lord);
        GAME_LOGGER.error(a + "|" + id + "|" + add + "|" + count);
    }

    /**
     * 武将
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param heroId
     * @param count
     * @param add
     */
    static public void hero(AwardFrom from, Account account, Lord lord, int heroId, int count, int add, long endtime, long cdtime) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("hero", from, account, lord);
        GAME_LOGGER.error(a + "|" + heroId + "|" + count + "|" + add + "|" + endtime + "|" + cdtime);
    }

    static public void awakenHero(AwardFrom from, Account account, Lord lord, AwakenHero awakenHero, int newHeroId) {
        if (account == null || lord == null) {
            return;
        }

        StringBuffer skill = new StringBuffer();
        Iterator<Entry<Integer, Integer>> it = awakenHero.getSkillLv().entrySet().iterator();
        while (it.hasNext()) {
            Entry<Integer, Integer> entry = it.next();
            skill.append(entry.getKey()).append("_").append(entry.getValue()).append("#");
        }
        if (skill.length() > 0) {
            skill.delete(skill.length() - 1, skill.length());
        }
        String a = getCommonParams("awakenHero", from, account, lord);
        GAME_LOGGER.error(a + "|" + awakenHero.getKeyId() + "|" + awakenHero.isUsed() + "|" + skill + "|" + awakenHero.getHeroId() + "|" + newHeroId);
    }

    /**
     * 统帅提升
     *
     * @param lord
     * @param cost
     * @param type 1.金币  2.道具
     **/
    static public void command(AwardFrom from, Account account, Lord lord, int type) {
        if (account == null || lord == null) {
            return;
        }
        int serverId = account.getServerId();
        long lordId = lord.getLordId();
        String nick = "\"" + lord.getNick() + "\"";
        int vip = lord.getVip();
        int level = lord.getLevel();
        String a = "command|" + from.getCode() + "|" + serverId + "|" + lordId + "|" + nick + "|" + vip + "|" + level + "|" + lord.getCommand() + "|" + type;
        GAME_LOGGER.error(a);
    }

    /**
     * 资源
     *
     * @param from
     * @param account
     * @param lord
     * @param resource
     * @param gold
     * @param id
     * @param count
     * @param add
     */
    static public void resource(AwardFrom from, Account account, Lord lord, Resource resource, int id, long add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("resource", from, account, lord);
        GAME_LOGGER.error(a + "|" + resource.getIron() + "|" + resource.getOil() + "|" + resource.getCopper() + "|" + resource.getSilicon() + "|"
                + resource.getStone() + "|" + id + "|" + add);
    }

    /**
     * 军工材料
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param materialId
     * @param count
     * @param add
     */
    static public void militaryMaterial(AwardFrom from, Account account, Lord lord, int materialId, long count, long add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("militaryMaterial", from, account, lord);
        GAME_LOGGER.error(a + "|" + materialId + "|" + count + "|" + add);
    }

    /**
     * 竞技场积分
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param score
     */
    static public void arena(AwardFrom from, Account account, Lord lord, int gold, int score, int add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("arena", from, account, lord);
        GAME_LOGGER.error(a + "|" + gold + "|" + score + "|" + add);
    }

    /**
     * 声望
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param frame
     * @param add
     */
    static public void fame(AwardFrom from, Account account, Lord lord, int fameLv, int fame, int add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("frame", from, account, lord);
        GAME_LOGGER.error(a + "|" + fameLv + "|" + fame + "|" + add);
    }

    /**
     * 科技
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param fameLv
     * @param fame
     * @param add
     */
    static public void science(AwardFrom from, Account account, Lord lord, int scienceId, int lv) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("science", from, account, lord);
        GAME_LOGGER.error(a + "|" + scienceId + "|" + lv);
    }

    /**
     * 建筑
     *
     * @param from
     * @param account
     * @param lord
     * @param buildId
     * @param lv
     */
    static public void build(AwardFrom from, Account account, Lord lord, int buildId, int lv) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("build", from, account, lord);
        GAME_LOGGER.error(a + "|" + buildId + "|" + lv);
    }

    /**
     * 坦克损失
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param tankId
     * @param count
     * @param add
     * @param disappear 永久损失
     * @param param
     */
    static public void tank(AwardFrom from, Account account, Lord lord, int tankId, int count, int add, int disappear, long param) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("tank", from, account, lord);
        GAME_LOGGER.error(a + "|" + tankId + "|" + count + "|" + add + "|" + disappear + "|" + param);
    }

    /**
     * 军团贡献
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param donate
     * @param weekDonate
     * @param add
     */
    static public void contribution(AwardFrom from, Account account, Lord lord, int donate, int weekDonate, int add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("contribution", from, account, lord);
        GAME_LOGGER.error(a + "|" + donate + "|" + weekDonate + "|" + add);
    }

    /**
     * 军团贡献减少
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param donate
     * @param weekDonate
     * @param add
     */
    static public void subContribution(AwardFrom from, Account account, Lord lord, int donate, int weekDonate, int del) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("subContribution", from, account, lord);
        GAME_LOGGER.error(a + "|" + donate + "|" + weekDonate + "|" + del);
    }

    /**
     * 记录操作邮件
     *
     * @param from
     * @param account
     * @param lord
     * @param mail    void
     */
    static public void mail(AwardFrom from, Account account, Lord lord, Mail mail) {
        if (account == null || lord == null) {
            return;
        }

        List<CommonPb.Award> awardList = mail.getAward();
        if (awardList == null || awardList.isEmpty()) {
            return;
        }

        JSONArray arr = new JSONArray();
        for (CommonPb.Award e : awardList) {
            arr.add(e.getType());
            arr.add(e.getId());
            arr.add(e.getCount());
        }
        String a = getCommonParams("mail", from, account, lord);

        GAME_LOGGER.error(a + "|" + mail.getKeyId() + "|" + arr.toJSONString());

    }

    /**
     * 能晶
     *
     * @param from
     * @param account
     * @param lord
     * @param energyStoneId
     * @param count
     * @param add
     */
    static public void energyStone(AwardFrom from, Account account, Lord lord, int energyStoneId, long count,
                                   long add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("energyStone", from, account, lord);
        GAME_LOGGER.error(a + "|" + energyStoneId + "|" + count + "|" + add);
    }

    public static void exploit(AwardFrom from, Account account, Lord lord, long exploit,
                               long add) {
        String a = getCommonParams("exploit", from, account, lord);
        GAME_LOGGER.error(a + "|" + exploit + "|" + add);
    }

    /**
     * 荒宝碎片
     *
     * @param from
     * @param account
     * @param lord
     * @param count
     * @param add
     */
    public static void huangbao(AwardFrom from, Account account, Lord lord, long count, long add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("huangbao", from, account, lord);
        GAME_LOGGER.error(a + "|" + count + "|" + add);
    }

    /**
     * 赏金碎片
     *
     * @param from
     * @param account
     * @param lord
     * @param count
     * @param add
     */
    public static void bounty(AwardFrom from, Account account, Lord lord, long count, long add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("bounty", from, account, lord);
        GAME_LOGGER.error(a + "|" + count + "|" + add);
    }

    /**
     * 军团矿区积分
     *
     * @param party
     * @param player
     * @param addScore
     */
    public static void partyScore(PartyData party, Player player, int addScore) {
        GAME_LOGGER.error("partyScore|" + party.getPartyId() + "|" + party.getPartyName() + "|" + party.getScore() + "|"
                + player.roleId + "|" + "\"" + player.lord.getNick() + "\"" + "|" + player.seniorScore + "|" + addScore);
    }

    /**
     * 活动道具记录
     *
     * @param from
     * @param account
     * @param lord
     * @param gold
     * @param propId
     * @param count
     * @param add
     */
    static public void activityProp(AwardFrom from, int activityId, Account account, Lord lord, int propId, int count, int add) {
        if (account == null || lord == null) {
            return;
        }
        String a = getCommonParams("activityProp", from, account, lord);
        GAME_LOGGER.error(a + "|" + activityId + "|" + propId + "|" + count + "|" + add);
    }

    /**
     * 每小时统计资源 自增量
     *
     * @param account
     * @param lord
     * @param resource
     * @param resources
     */
    static public void resourceTimeAdd(Account account, Lord lord, Resource resource, long[] resources) {
        if (account == null || lord == null) {
            return;
        }
        int serverId = account.getServerId();
        long lordId = lord.getLordId();
        int vip = lord.getVip();
        int level = lord.getLevel();
        String nick = "\"" + lord.getNick() + "\"";
        String a = "resourceTimeAdd|" + serverId + "|" + lordId + "|" + nick + "|" + vip + "|" + level + "|" + lord.getGold();
        GAME_LOGGER.error(a + "|" + resource.getIron() + "|" + resource.getOil() + "|" + resource.getCopper() + "|" + resource.getSilicon() + "|"
                + resource.getStone() + "|" + resources[0] + "|" + resources[1] + "|" + resources[2] + "|" + resources[3] + "|" + resources[4]);
    }


    /**
     * 在线人数统计
     *
     * @param channel
     * @param num
     */
    static public void onlineNum(int channel, int num) {
        int serverId = GameServer.ac.getBean(ServerSetting.class).getServerID();
        if (channel == -1) {
            GAME_LOGGER.error("playerAllNum|" + serverId + "|" + num);
        } else {
            GAME_LOGGER.error("playerChannelNum|" + serverId + "|" + channel + "|" + num);
        }
    }


    /**
     * 举报打印
     *
     * @param player
     * @param target
     * @param content
     */
    static public void tipGuy(Player player, Player target, String content) {
        int serverId = target.account.getServerId();
        long playerId = player.lord.getLordId();
        String playerName = "\"" + player.lord.getNick() + "\"";
        long targetId = target.lord.getLordId();
        String targetName = "\"" + target.lord.getNick() + "\"";
        int targetVip = target.lord.getVip();
        int targetLv = target.lord.getLevel();
        GAME_LOGGER.error("tipGuy|" + serverId + "|" + playerId + "|" + playerName + "|" + targetId + "|" + targetName + "|"
                + targetVip + "|" + targetLv + "|" + content);
    }

    /**
     * 返利我做主记录日志
     * 格式：activity|activityId|awardId|serverId|lordId|nick|0|0|[num,rate,money]
     *
     * @param player
     * @param num    转动次数
     * @param rate   转动返利比例
     * @param money  转动返利金额
     */
    static public void payRebate(Player player, int awardId, int num, long rate, long money) {
        Lord lord = player.lord;
        String nick = "\"" + lord.getNick() + "\"";
        String str = "activity|" + AwardFrom.PAY_TURN_TABLE.getCode() + "|" + player.account.getServerId() + "|" + lord.getLordId() +
                "|" + nick + "|" + lord.getVip() + "|" + lord.getLevel() + "|" + lord.getGold() + "|" + ActivityConst.ACT_PAY_TURNTABLE_ID + "|" +
                awardId + "|0|0|";

        GAME_LOGGER.error(str + "[" + num + "," + rate + "," + money + "]");
    }

    /**
     * 西点学院玩家学分日志
     * 格式：activity|activityId|awardId|ServerId|lordId|nick|累计学分|增加学分|[[当前学科id,当前学科点数,累计学科点数],[消费type,消费id,消费count],[[奖励type,奖励id,奖励count],...]]
     *
     * @param player
     * @param awardId
     * @param subjectLog 记录[当前学科id,当前学科点数,累计学科点数]
     * @param costLog    记录[消费type,消费id,消费count]
     * @param awardLog   记录[奖励type,奖励id,奖励count]列表
     * @param point      本次学分
     * @param increase   增加的学分
     */
    static public void actCollege(Player player, int awardId, int point, int increase, String subjectLog, String costLog, String awardLog) {
        Lord lord = player.lord;
        String nick = "\"" + lord.getNick() + "\"";
        String str = "activity|" + AwardFrom.DO_ACT_COLLEGE.getCode() + "|" + player.account.getServerId() + "|" + lord.getLordId() +
                "|" + nick + "|" + lord.getVip() + "|" + lord.getLevel() + "|" + lord.getGold() + "|" + ActivityConst.ACT_COLLEGE + "|" +
                awardId + "|" + point + "|" + increase + "|";
        GAME_LOGGER.error(str + "[" + subjectLog + "," + costLog + "," + awardLog + "]");
    }

    /**
     * 记录排行榜日志
     * 格式：activity|activityId|awardId|serverId|lordId|nick|[score,rank]
     *
     * @param player
     * @param rankList
     */
    public static void logRank(Player player, int awardId, long score, int increase, int rank) {
        Lord lord = player.lord;
        String nick = "\"" + lord.getNick() + "\"";
        String str = "activity|" + AwardFrom.ACT_PIRATE_LOTTERY.getCode() + "|" + player.account.getServerId() + "|" + lord.getLordId() +
                "|" + nick + "|" + lord.getVip() + "|" + lord.getLevel() + "|" + lord.getGold() + "|" + ActivityConst.ACT_PIRATE + "|" +
                awardId + "|" + score + "|" + increase + "|";

        GAME_LOGGER.error(str + "[" + score + "," + rank + "]");
    }

    /**
     * 军备洗练日志
     */
    public static void logLordEquipChange(Player player, AwardFrom from, LordEquip leq) {
        Lord lord = player.lord;
        String a = getCommonParams("lordEquipChange", from, player.account, lord);
        StringBuilder sb = new StringBuilder();
        List<List<Integer>> lordEquipSkillList = leq.getLordEquipSkillList();
        for (List<Integer> skill : lordEquipSkillList) {
            sb.append(skill.get(0) + ",");
        }
        if (sb.length() > 0) {
            sb.setLength(sb.length() - 1);
        }
        a = a + "|" + leq.getEquipId() + "|[" + sb.toString() + "]";
        GAME_LOGGER.error(a);
    }

    /**
     * 删除邮件时记录自动收取附件
     *
     * @param autoDelMail
     * @param player
     * @param mail
     */
    public static void autoDelMail(AwardFrom from, Player player, Mail mail) {
        String a = getCommonParams("autodelmail", from, player.account, player.lord);

        StringBuilder awards = new StringBuilder();

        for (CommonPb.Award e : mail.getAward()) {
            awards.append("[" + e.getType() + "," + e.getId() + "," + e.getCount() + "],");
        }
        if (awards.length() > 0) {
            awards.setLength(awards.length() - 1);
        }

        GAME_LOGGER.error(a + "|" + "[" + awards + "]");
    }

    public static void logActivity(StaticActivityDataMgr staticActivityDataMgr, Player player, int activityId, AwardFrom from, int type, int id, int count, int gold) {
        int awardId = staticActivityDataMgr.getActivityById(activityId).getPlan().getAwardId();
        String a = getCommonParams("logActivity", from, player.account, player.lord);
        //如果奖励是金币，则消耗金币为获取金币数
        if (type == AwardType.GOLD) {
            gold = count;
        } else {
            gold = -gold;
        }
        //奖励id，物品类型（大类），物品id（小类），添加或减少数量
        GAME_LOGGER.error(a + "|" + gold + "|" + activityId + "|" + awardId + "|" + type + "|" + id + "|" + count);
    }

    /**
     * 活动奖励活的
     *
     * @param staticActivityDataMgr
     * @param player
     * @param actVipGift
     * @param vipGift
     * @param awardList
     * @param price
     */
    public static void logActivity(StaticActivityDataMgr staticActivityDataMgr, Player player, int activityId, AwardFrom from, List<List<Integer>> awardList, int gold) {
        // 多个奖励格式0|0|0|[[type,id,count]...]
        String award;
        if (awardList.size() == 1) {
            List<Integer> list = awardList.get(0);
            logActivity(staticActivityDataMgr, player, activityId, from, list.get(0), list.get(1), list.get(2), gold);
            return;
        }
        int awardId = staticActivityDataMgr.getActivityById(activityId).getPlan().getAwardId();
        gold = -gold;
        StringBuilder sb = new StringBuilder();
        for (List<Integer> list : awardList) {
            sb.append("[" + list.get(0) + "," + list.get(1) + "," + list.get(2) + "],");
        }

        if (sb.length() > 0) {
            sb.setLength(sb.length() - 1);
        }

        award = "0|0|0|[" + sb + "]";

        GAME_LOGGER.error(getCommonParams("logActivity", from, player.account, player.lord) + "|" + gold + "|"
                + activityId + "|" + awardId + "|" + award);
    }

    /**
     * 记录每月签到数据
     *
     * @param from
     * @param player
     * @param month  签到月份
     * @param day    每月的第几天签到
     * @param days   当月总共签到天数
     */
    static public void logMonthSign(AwardFrom from, Player player, int month, int day, int days) {
        String a = getCommonParams("monthSign", from, player.account, player.lord);
        GAME_LOGGER.error(a + "|" + month + "|" + day + "|" + days);
    }

    /**
     * 记录能量灌注活动的充值日志
     *
     * @param dayiy
     * @param topup
     * @param statusMap
     */
    public static void logPayCumulative(Player player, int dayiy, int topup, Map<Integer, Integer> statusMap) {
        String a = getCommonParams("payCumulative", AwardFrom.ACT_CUMULATIVE, player.account, player.lord) + "|" +
                //第几天|充值金币|大奖可领状态|第一天可领状态|第二天可领状态|第三天可领状态
                dayiy + "|" + topup + "|" + statusMap.get(0) + "|" + statusMap.get(1) + "|" + statusMap.get(2) + "|" + statusMap.get(3);
        GAME_LOGGER.error(a);
    }

    /**
     * 记录能量灌注活动领奖日志
     *
     * @param player
     * @param day
     */
    public static void logGetActCumulative(Player player, int day) {
        String a = getCommonParams("getCumulative", AwardFrom.ACT_CUMULATIVE, player.account, player.lord) + "|" + day;
        GAME_LOGGER.error(a);
    }

    /**
     * 自选豪礼领奖日志
     *
     * @param player
     * @param id     领奖id
     * @param topup  充值金币
     * @param get    领取次数
     */
    public static void logActChooseGift(Player player, int id, int topup, int get) {
        String a = getCommonParams("getChooseGift", AwardFrom.ACT_CHOOSE_GIFT, player.account, player.lord) +
                "|" + id + "|" + topup + "|" + get;
        GAME_LOGGER.error(a);
    }

    /**
     * 购买皮肤
     *
     * @param awardFrom
     * @param account
     * @param lord
     * @param i
     * @param skinId
     * @param count
     * @param count2
     */
    public static void skin(AwardFrom from, Account account, Lord lord, int skinId, int count, int add) {
        String a = getCommonParams("skin", from, account, lord) + "|" + skinId + "|" + count + "|" + add;
        GAME_LOGGER.error(a);
    }

    /**
     * 记录玩家等级升级日志
     *
     * @param account
     * @param lord
     * @param oldLv
     */
    public static void logUpLevel(Player player, int oldLv) {
        int serverId = player.account.getServerId();
        Lord lord = player.lord;
        long lordId = lord.getLordId();
        int vip = lord.getVip();
        int level = lord.getLevel();
        String nick = "\"" + lord.getNick() + "\"";
        String a = "upLv|" + serverId + "|" + lordId + "|" + nick + "|" + vip + "|"
                + level + "|" + oldLv;
        GAME_LOGGER.error(a);
    }


    /**
     * 记录玩家坦克转换数据
     */
    public static void tankConvert(Player player, int count, int srcTankId, int dstTankId) {
        int serverId = player.account.getServerId();
        Lord lord = player.lord;
        long lordId = lord.getLordId();
        int vip = lord.getVip();
        int level = lord.getLevel();
        String nick = "\"" + lord.getNick() + "\"";
        String a = "tankConvert|" + serverId + "|" + lordId + "|" + nick + "|" + vip + "|"
                + level + "|" + srcTankId + "|" + dstTankId + "|" + count;
        GAME_LOGGER.error(a);
    }

}