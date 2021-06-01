package com.game.actor.role.lsn;

import com.game.actor.rank.RankEventService;
import com.game.actor.role.PlayerEvent;
import com.game.constant.TankType;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticTankDataMgr;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticHero;
import com.game.domain.s.StaticTank;
import com.game.domain.sort.HeroSort;
import com.game.manager.PlayerDataManager;
import com.game.server.Actor.IMessage;
import com.game.server.Actor.IMessageListener;
import com.game.service.FightService;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 计算玩家战力
 *
 * @author zhangdh
 * @ClassName: CalcStrongestFormLsn
 * @Description:
 * @date 2017-07-06 10:58
 */
@Service
public class CalcStrongestFormLsn0 implements IMessageListener {

    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private StaticTankDataMgr staticTankDataMgr;
    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;
    @Autowired
    private FightService fightService;

    @Autowired
    private RankEventService rankEventService;

    @Override
    public void onMessage(IMessage msg) {
        Player player = ((PlayerEvent) msg).getPlayer();
        long start = System.nanoTime();
        recalcMaxFight(player);
        long end = System.nanoTime();
        if (end - start > 1000000) {
            LogUtil.common(String.format("calc lord :%s, strongest form cost  :%d ms", player.lord.getNick(), (end - start) / 1000000));
        }
    }

    /**
     * 计算玩家当前状态下理论上可达到最大战力的阵形
     *
     * @param player
     * @return
     */
    public void recalcMaxFight(Player player) {
        try {
            int flv = Math.max(player.building.getFactory1(), player.building.getFactory2());
            //可生产的4中最牛逼的坦克
            Map<Integer, StaticTank> staticTankMap = staticTankDataMgr.getCanBuildMaxTank4Type(player.lord.getLevel(), flv, TankType.Tank, TankType.Chariot, TankType.Artillery, TankType.Rocket);
            //开放的格子数
            int slotCount = playerDataManager.formSlotCount(player.lord.getLevel());
            //最强战力
            Object[] formInfo = calcMaxFight(player, staticTankMap, slotCount);
            long maxFight = (long)formInfo[1];
            if (maxFight != player.lord.getMaxFight()) {
                player.lord.setMaxFight(maxFight);
                //更新玩家最强实力排行榜
                rankEventService.upsertStrongestFormRank(player);
                printForm(player, (Form) formInfo[0], maxFight);
            }
        } catch (Exception e) {
            e.printStackTrace();
            LogUtil.error("", e);
        }
    }

    /**
     * 遍历所有英雄将英雄代入阵形中计算阵形战力
     *
     * @param player
     * @param staticTankMap
     * @param sltCnt
     * @return
     */
    private Object[] calcMaxFight(Player player, Map<Integer, StaticTank> staticTankMap, int sltCnt) {
        Object[] maxFormInfo = new Object[]{null, 0};
        if (!player.awakenHeros.isEmpty()) {
            List<AwakenHero> lst = findStrongestAwakenHero(player);
            for (AwakenHero awakenHero : lst) {
                StaticHero staticHero = staticHeroDataMgr.getStaticHero(awakenHero.getHeroId());
                Form form = new Form(awakenHero, 0);
                int maxTankCount = playerDataManager.formTankCount(player, staticHero, awakenHero);
                Object[] formInfo = calcMaxFightTank(player, staticTankMap, form, maxTankCount, sltCnt);
                if ((Integer) formInfo[1] > (Integer) maxFormInfo[1]) {
                    maxFormInfo = formInfo;
                }
            }
        }

        //计算普通将领阵形战力
        if (!player.heros.isEmpty()) {
            StaticHero staticHero = findStrongestHeroWithOutAwaken(player);
            if (staticHero != null) {
                Form form = new Form(null, staticHero.getHeroId());
                int maxTankCount = playerDataManager.formTankCount(player, staticHero, null);
                Object[] formInfo = calcMaxFightTank(player, staticTankMap, form, maxTankCount, sltCnt);
                if ((Integer) formInfo[1] > (Integer) maxFormInfo[1]) {
                    maxFormInfo = formInfo;
                }
            }
        }

        //没有将领的阵形
        if (maxFormInfo[0] == null) {
            Form form = new Form(null, 0);
            int maxTankCount = playerDataManager.formTankCount(player, null, null);
            Object[] formInfo = calcMaxFightTank(player, staticTankMap, form, maxTankCount, sltCnt);
            if ((Integer) formInfo[1] > (Integer) maxFormInfo[1]) {
                maxFormInfo = formInfo;
            }
        }

        return maxFormInfo;
    }

    /**
     * 根据设置的英雄计算最强阵容
     *
     * @param player
     * @param staticTankMap
     * @param form          以及各设置了英雄的初始阵形
     * @param maxTankCount
     * @param sltCnt
     * @return
     */
    private Object[] calcMaxFightTank(Player player, Map<Integer, StaticTank> staticTankMap, Form form, int maxTankCount, int sltCnt) {
        StaticTank staticTank = null;
        Object[] formInfo = new Object[]{form, 0};
        for (Map.Entry<Integer, StaticTank> entry : staticTankMap.entrySet()) {
            Form destForm = new Form(form.getAwakenHero(), form.getCommander());
            StaticTank stk = entry.getValue();
            for (int i = 0; i < sltCnt; i++) {
                destForm.p[i] = stk.getTankId();
                destForm.c[i] = maxTankCount;
            }
            long fight = fightService.calcFormFight(player, destForm);
            if (fight > (Integer) formInfo[1]) {
                formInfo[0] = destForm;
                formInfo[1] = fight;
                staticTank = entry.getValue();
            }
        }
        return replaceGoldTank(player, (Form) formInfo[0], (long) formInfo[1], staticTank, maxTankCount, sltCnt);
    }

    /**
     * 用金币坦克替换掉阵形里面的普通坦克，如果替换后的战力比原战力高的话
     *
     * @param player
     * @param form         已经设置好英雄与可建造的坦克的最强阵容
     * @param fight
     * @param sbtk
     * @param maxTankCount
     * @param sltCnt
     * @return
     */
    private Object[] replaceGoldTank(Player player, Form form, long fight, StaticTank sbtk, int maxTankCount, int sltCnt) {
        //搜集玩家身上可用的所有金币坦克
        Map<Integer, Tank> tanks = collectGoldTanks(player);
        Object[] max_formInfo = new Object[]{form, fight};
        for (Map.Entry<Integer, Tank> entry : tanks.entrySet()) {
            StaticTank sgtk = staticTankDataMgr.getStaticTank(entry.getValue().getTankId());
            //金币坦克判断
            if (sgtk != null && sgtk.getCanBuild() == 1 && sgtk.getDestroyMilitary() > 0) {
                Tank tk = entry.getValue();
                if (sgtk.getType() == sbtk.getType()) {
                    //如果最强可建造的坦克类型与此金币坦克类型相同，但金币坦克最大战力小于可建造的坦克类型则不做替换
                    int goldTankFight = sgtk.getFight() * Math.min(maxTankCount, tk.getCount());
                    if (goldTankFight <= sbtk.getFight() * maxTankCount) {
                        continue;
                    }
                }
                int i = 0;
                while (tk.getCount() > 0 && i < sltCnt) {
                    int tkc = Math.min(tk.getCount(), maxTankCount);
                    //替换掉第一个发现的非金币坦克
                    int tankId = ((Form) max_formInfo[0]).p[i];
                    if (tankId == 0 || tankId == sbtk.getTankId()) {
                        Object[] formInfo = replaceSignleGoldTank(player, (Form) max_formInfo[0], (long) max_formInfo[1], sgtk, tkc, i);
                        if ((Long) formInfo[1] > (Long) max_formInfo[1]) {
                            max_formInfo = formInfo;
                            tk.setCount(tk.getCount() - tkc);
                        }
                    }
                    i++;
                }
            }
        }
        return max_formInfo;
    }

    /**
     * 打印阵形信息
     *
     * @param player
     * @param form
     * @param fight
     */
    private void printForm(Player player, Form form, long fight) {
        //打印最大战力阵容信息
        StringBuilder logSb = new StringBuilder().append("\n");
        for (int i = 0; i < form.p.length; i++) {
            String pos_str = "[ X / 0 ]   ";
            if (form.p[i] != 0) {
                StaticTank stk = staticTankDataMgr.getStaticTank(form.p[i]);
                pos_str = String.format("[ %d / %d ]   ", form.p[i], form.c[i]);
            }
            logSb.append(pos_str);
            if (i == 2) logSb.append("\n");
        }
        LogUtil.common(String.format("\nnick :%s, max fight :%d, \ncommander :%d, form :%s", player.lord.getNick(), fight, form.getHero(), logSb));
    }

    private Object[] replaceSignleGoldTank(Player player, Form form, long fight, StaticTank sgtk, int maxTankCount, int idx) {
        Form destForm = new Form(form);
        destForm.p[idx] = sgtk.getTankId();
        destForm.c[idx] = maxTankCount;
        long destFight = fightService.calcFormFight(player, destForm);
        if (destFight > fight) {
            return new Object[]{destForm, destFight};
        }
        return new Object[]{form, fight};
    }

    /**
     * 搜集玩家当前身上所有的金币坦克,包括部队中的金币坦克
     *
     * @param player
     * @return
     */
    private Map<Integer, Tank> collectGoldTanks(Player player) {
        //玩家能够动用的金币坦克
        Map<Integer, Tank> tanks = new HashMap<>();
        for (Map.Entry<Integer, Tank> entry : player.tanks.entrySet()) {
            Tank tk = entry.getValue();
            if (tk.getCount() <= 0) continue;
            StaticTank sgtk = staticTankDataMgr.getStaticTank(entry.getValue().getTankId());
            if (sgtk != null && sgtk.getCanBuild() == 1 && sgtk.getDestroyMilitary() > 0) {
                tanks.put(tk.getTankId(), new Tank(tk.getTankId(), tk.getCount(), 0));
            }
        }
        for (Army army : player.armys) {
            Form form = army.getForm();
            for (int i = 0; i < form.p.length; i++) {
                if (form.p[i] == 0 || form.c[i] == 0) continue;
                StaticTank sgtk = staticTankDataMgr.getStaticTank(form.p[i]);
                if (sgtk != null && sgtk.getCanBuild() == 1 && sgtk.getDestroyMilitary() > 0) {
                    Tank tk = tanks.get(form.p[i]);
                    if (tk == null) {
                        tanks.put(form.p[i], tk = new Tank(form.p[i], form.c[i], 0));
                    } else {
                        tk.setCount(tk.getCount() + form.c[i]);
                    }
                }
            }
        }
        return tanks;
    }

    /**
     * 找到玩家最强的非觉醒将领
     *
     * @param player
     * @return
     */
    private StaticHero findStrongestHeroWithOutAwaken(Player player) {
        TreeMap<HeroSort, StaticHero> sorts = new TreeMap<>();
        for (Map.Entry<Integer, Hero> entry : player.heros.entrySet()) {
            Hero hero = entry.getValue();
            if (hero.getCount() > 0) {
                StaticHero staticHero = staticHeroDataMgr.getStaticHero(hero.getHeroId());
                if (staticHero != null && staticHero.getType() == 2) {//武官才计算
                    sorts.put(new HeroSort(hero.getHeroId(), -staticHero.getOrder()), staticHero);
                }
            }
        }
        if (!sorts.isEmpty()) {
            return sorts.firstEntry().getValue();
        }
        return null;
    }

    /**
     * 返回最牛逼的觉醒将领列表,
     *
     * @param player
     * @return 觉醒将领。
     */
    private List<AwakenHero> findStrongestAwakenHero(Player player) {
        //KEY:技能ID,VALUE:觉醒将领（目前按照技能ID来分组）
        Map<Integer, List<HeroSort>> sorts = new HashMap<>();
        List<AwakenHero> retList = new ArrayList<>();
        for (Map.Entry<Integer, AwakenHero> entry : player.awakenHeros.entrySet()) {
            AwakenHero hero = entry.getValue();
            StaticHero staticHero = staticHeroDataMgr.getStaticHero(hero.getHeroId());
            if (staticHero != null && staticHero.getType() == 2) {
                List<HeroSort> lst = sorts.get(staticHero.getSkillId());
                if (lst == null) sorts.put(staticHero.getSkillId(), lst = new ArrayList<>());
                lst.add(new HeroSort(hero.getKeyId(), -hero.getHeroId()));//负数表示降序排列
            }
        }

        if (!sorts.isEmpty()) {
            for (Map.Entry<Integer, List<HeroSort>> entry : sorts.entrySet()) {
                List<HeroSort> lst = entry.getValue();
                Collections.sort(lst);
                AwakenHero awaken = player.awakenHeros.get(lst.iterator().next().getHeroId());
                retList.add(awaken);
            }
        }
        return retList;
    }


}
