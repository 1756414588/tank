package com.game.actor.role.lsn;

import com.game.actor.rank.RankEventService;
import com.game.actor.role.PlayerEvent;
import com.game.constant.Constant;
import com.game.constant.TankType;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticTankDataMgr;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticHero;
import com.game.domain.s.StaticTank;
import com.game.domain.sort.HeroSort;
import com.game.domain.sort.TankSort;
import com.game.manager.PlayerDataManager;
import com.game.server.Actor.IMessage;
import com.game.server.Actor.IMessageListener;
import com.game.service.FightService;
import com.game.util.LogUtil;
import com.game.util.NumberHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * 计算玩家战力
 * 玩家最强实力计算方法: 玩家可生产的坦克ID*max_count,金币坦克 *Math.min(remain, max_count).....
 * 排除装备算出战力后进行排序，选战力前6的作为最强实力
 *
 * @author zhangdh
 * @ClassName: CalcStrongestFormLsn
 * @Description:
 * @date 2017-07-06 10:58
 */
@Service
public class CalcStrongestFormLsn implements IMessageListener {

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
        if (end - start > NumberHelper.I_MILLION * 10) {//10毫秒
            LogUtil.common(String.format("calc lord :%s, strongest form cost  :%d ms", player.lord.getNick(), (end - start) / NumberHelper.I_MILLION));
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
            TreeMap<Long, Form> formMap = calcStrongestForm(player, staticTankMap, slotCount);
            //最强战力
            Map.Entry<Long, Form> entry = formMap.lastEntry();
            if (entry.getKey() != player.lord.getMaxFight()) {
                player.lord.setMaxFight(entry.getKey());
                //更新玩家最强实力排行榜
                rankEventService.upsertStrongestFormRank(player);
                printForm(player, entry.getValue(), entry.getKey());
            }
        } catch (Exception e) {
            e.printStackTrace();
            LogUtil.error("", e);
        }
    }

    private TreeMap<Long, Form> calcStrongestForm(Player player, Map<Integer, StaticTank> staticTankMap, int sltCnt) {
        TreeMap<Long, Form> treeMap = new TreeMap<>();
        //计算有觉醒将领的阵形
        if (!player.awakenHeros.isEmpty()) {
            List<AwakenHero> lst = findStrongestAwakenHero(player);
            for (AwakenHero awakenHero : lst) {
                StaticHero staticHero = staticHeroDataMgr.getStaticHero(awakenHero.getHeroId());
                Form form = new Form(awakenHero, 0);
                int maxTankCount = playerDataManager.formTankCount(player, staticHero, awakenHero);
                List<TankSort> sortTanks = calcTankSort(player, staticTankMap, staticHero, maxTankCount, sltCnt);
                for (int i = 0; i < sltCnt; i++) {
                    TankSort sort = sortTanks.get(i);
                    form.p[i] = sort.getTankId();
                    form.c[i] = sort.getCount();
                }
                long fight = fightService.calcFormFight(player, form) * Constant.STRONGEST_FORM_FIGHT_CALC_F / NumberHelper.TEN_THOUSAND;
                treeMap.put(fight, form);
            }
        }

        //计算普通将领阵形战力
        StaticHero staticHero = findStrongestHeroWithOutAwaken(player);
        Form form = new Form(null, staticHero != null ? staticHero.getHeroId() : 0);
        int maxTankCount = playerDataManager.formTankCount(player, staticHero, null);
        List<TankSort> sortTanks = calcTankSort(player, staticTankMap, staticHero, maxTankCount, sltCnt);
        for (int i = 0; i < sltCnt; i++) {
            TankSort sort = sortTanks.get(i);
            form.p[i] = sort.getTankId();
            form.c[i] = sort.getCount();
        }
        long fight = fightService.calcFormFight(player, form) * Constant.STRONGEST_FORM_FIGHT_CALC_F / NumberHelper.TEN_THOUSAND;
        treeMap.put(fight, form);
        return treeMap;
    }

    private List<TankSort> calcTankSort(Player player, Map<Integer, StaticTank> staticTankMap, StaticHero staticHero, int maxTankCount, int sltCnt) {
        List<TankSort> sorts = new ArrayList<>();
        for (Map.Entry<Integer, StaticTank> entry : staticTankMap.entrySet()) {
            StaticTank staticTank = entry.getValue();
            int fight = (int) (fightService.calcTankFightWithoutEquip(player, staticTank.getTankId(), staticHero) * maxTankCount);
            for (int i = 0; i < sltCnt; i++) {
                sorts.add(new TankSort(staticTank, maxTankCount, fight));
            }
        }
        Map<Integer, Tank> glodTanks = collectGoldTanks(player);
        for (Map.Entry<Integer, Tank> entry : glodTanks.entrySet()) {
            Tank tank = entry.getValue();
            StaticTank staticTank = staticTankDataMgr.getStaticTank(tank.getTankId());
            if (staticTank != null) {
                for (int i = 0; i < sltCnt; i++) {
                    int subCount = Math.min(tank.getCount(), maxTankCount);
                    int fight = (int) (fightService.calcTankFightWithoutEquip(player, staticTank.getTankId(), staticHero) * subCount);
                    sorts.add(new TankSort(staticTank, subCount, fight));
                    int remain = tank.getCount() - subCount;
                    tank.setCount(remain);
                    if (remain <= 0) break;
                }
            }
        }
        Collections.sort(sorts);
//        if (player.lord.getNick().equalsIgnoreCase("sl1")) {
//            LogUtil.common("---------> " + Arrays.toString(sorts.toArray()));
//        }
        return sorts.subList(0, sltCnt);
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
        List<Army> armyList = new ArrayList<>();
        armyList.addAll(player.armys);
        for (Army army : armyList) {
            Form form = army.getForm();
            for (int i = 0; i < form.p.length; i++) {
                if (form.p[i] == 0 || form.c[i] == 0) continue;
                StaticTank sgtk = staticTankDataMgr.getStaticTank(form.p[i]);
                if (sgtk != null && sgtk.getCanBuild() == 1 && sgtk.getDestroyMilitary() > 0) {
                    Tank tk = tanks.get(form.p[i]);
                    if (tk == null) {
                        tanks.put(form.p[i], new Tank(form.p[i], form.c[i], 0));
                    } else {
                        tk.setCount(tk.getCount() + form.c[i]);
                    }
                }
            }
        }
        return tanks;
    }

    /**
     * 找到玩家最强的非觉醒将领<br>
     * 根据s_hero表中的order 字段来排序，order越小，英雄越强力
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

    public static void main(String[] args) {
        final List<Integer> cawList = new CopyOnWriteArrayList<>();
        for (int i = 0; i < 50; i++) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    for (int j = 1001; j < 10000; j++) {
                        cawList.add(j);
//                        try {
//                            Thread.sleep(2);
//                        } catch (InterruptedException e) {
//                            e.printStackTrace();
//                        }
                    }
                }
            }).start();
        }

        for (int i = 0; i < 100; i++) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    while(!cawList.isEmpty()){
                        for (Integer obj : cawList) {
                            if (cawList.remove(obj)) {
                                LogUtil.info(Thread.currentThread().getName() + " read obj : " + obj);
                            }
//                            try {
//                                Thread.sleep(1);
//                            } catch (InterruptedException e) {
//                                e.printStackTrace();
//                            }
                        }
                    }
                }
            }).start();
        }

    }
}
