package merge.v2;

import com.game.constant.*;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import com.google.protobuf.InvalidProtocolBufferException;
import merge.MServer;
import merge.MyBatisM;
import merge.v2.thread.MergePlayerThread;

import java.util.*;
import java.util.concurrent.CountDownLatch;

/**
 * @author zhangdh
 * @ClassName: MergePlayerUtils
 * @Description: 合并玩家
 * @date 2017-08-05 15:44
 */
public class MergePlayerUtils {

    public static void mergePlayerInThread(MergeDataMgr dataMgr, MServer slave) {
        MyBatisM slaveDb = slave.myBatisM;

        int sid = slave.getServerId();//服务器ID
        String sname = slave.getServerName();//服务器名字

        //查询slave服中有效角色列表
        List<Long> totalLordIds = slaveDb.getLordDao().selectLordNotSmallIds();
        slave.totalIds.addAll(totalLordIds);

        //初始化处理线程
        int default_thread_count = 20;
        CountDownLatch countDownLatch = new CountDownLatch(default_thread_count);
        Map<Integer, MergePlayerThread> threadMap = new HashMap<>();
        for (int idx = 0; idx < default_thread_count; idx++) {
            threadMap.put(idx, new MergePlayerThread(dataMgr, slave, countDownLatch, idx));
        }

        //将玩家分配给指定玩家
        for (Long lordId : slave.totalIds) {
            int idx = (int) (lordId % default_thread_count);
            MergePlayerThread handThread = threadMap.get(idx);
            handThread.addHandLord(lordId);
        }

        //启动处理线程
        for (Map.Entry<Integer, MergePlayerThread> entry : threadMap.entrySet()) {
            entry.getValue().start();
        }

        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            LogUtil.error("多线程模块错误，请联系开发人员，同时删除合服Master库，以便重新合服", e);
            System.exit(-1);
        }
    }


    /**
     * 合并一个玩家数据
     *
     * @param dataMgr
     * @param slave
     * @param lordId
     * @param nowSec
     */
    public static void mergePlayer(MergeDataMgr dataMgr, MServer slave, long lordId, int nowSec) {
        MyBatisM slaveDb = slave.myBatisM;
        int sid = slave.getServerId();
        String sname = slave.getServerName();
        try {
            Lord lord = slaveDb.getLordDao().selectLordById(lordId);
            Player player = new Player(lord, nowSec);
            //重新设置玩家地图坐标
            dataMgr.addNewPlayer(player);
            //如果玩家名字重复则更新玩家名字
            String uniqueName = dataMgr.getLordUniqueName(lord.getNick(), slave.getNickSuffix(), slave.hasMerge);
            lord.setNick(uniqueName);

            DataNew data = slaveDb.getDataNewDao().selectData(lordId);
            if (data == null) {
                LogUtil.error(String.format("sid :%d, sname :%s, lordId :%d, data not found", sid, sname, lordId));
            }

            try {
                player.dserNewData(data);
            } catch (InvalidProtocolBufferException e) {
                LogUtil.error(String.format("sid :%d, sname :%s, lordId :%d, parse p_data error", sid, sname, lordId), e);
                return;
            }

            //部队返回有可能增加资源
            player.resource = slaveDb.getResourceDao().selectResource(lordId);
            if (player.resource == null) {
                LogUtil.error(String.format("sid :%d, sname :%s, lordId :%d, resouce not found", sid, sname, lordId));
                return;
            }

            //building 不能为NULL
            player.building = slaveDb.getBuildingDao().selectBuilding(lordId);
            if (player.building == null) {
                LogUtil.error(String.format("sid :%d, sname :%s, lordId :%d, building not found", sid, sname, lordId));
                return;
            }

            //Account 不能为NULL
            player.account = slaveDb.getAccountDao().selectAccountByLordId(lordId);

            if (player.account == null) {
                LogUtil.error(String.format("sid :%d, sname :%s, lordId :%d, account not found", sid, sname, lordId));
                return;
            }

            //ad 玩家广告信息
            player.advertisement = slaveDb.getAdDao().selectAdvertisement(lordId);

            //玩家举报信息 可以为NULL
            TipGuy tipGuy = slaveDb.getTipGuyDao().selectTipGuyByLordId(lordId);

            //玩家充值记录
            List<Pay> pays = slaveDb.getPayDao().selectRolePay(player.account.getServerId(), lordId);

            //邮件数据
            List<NewMail> newMails = slaveDb.getMailDao().selectByLordId(lordId);
            if (newMails != null && !newMails.isEmpty()) {
                Iterator<NewMail> iter = newMails.iterator();
                while (iter.hasNext()) {
                    NewMail newMail = iter.next();
                    if (newMail.getType() == MailType.ARENA_MAIL || newMail.getType() == MailType.ARENA_GLOBAL_MAIL) {
                        iter.remove();
                    }
                }
            }

            boolean isLeguats = dataMgr.isLegatus(lordId);

            //处理玩家非军团数据
            handData(player, slave.totalIds, isLeguats);

            dataMgr.saveMergePlayer(sid, sname, player, player.advertisement, tipGuy, pays, newMails);

            LogUtil.info("merge player  serverId={},serverName={}, name={},roleId={} succ",sid, sname,player.lord.getNick(), lordId);
        } catch (Exception e) {
            LogUtil.error(String.format("sid :%d, sname :%s, lordId :%d", sid, sname, lordId), e);
            LogUtil.error("合服报错",e);
            System.exit(-1);
        }

    }

    /**
     * 处理玩家数据
     *
     * @param player    玩家信息
     * @param ids       本服所有lordId
     * @param isLeguats true - 军团长
     */
    private static void handData(Player player, Set<Long> totalIds, boolean isLeguats) {
        //合服时部队返回
        retreatEnd(player);

        //玩家叛军数据处理
        handRebelData(player);

        //玩家军事矿区数据处理
        handSenior(player);

        //玩家竞技场邮件处理
        handArenaMail(player);

        //处理玩家好友信息
        handFrind(player, totalIds);

        //合服添加防护罩
        addEffect(player, EffectType.ATTACK_FREE, MergeDataMgr.BUFF_FREE_TIME_BY_MERGE);

        //给玩家一个免费的改名卡
        addProp(player, PropId.CHANGE_NAME, 1);

        //如果玩家是军团长则给予一个军团改名卡
        if (isLeguats) {
            addProp(player, PropId.PARTY_RENAME_CARD, 1);
        }
    }

    /**
     * 清除玩家叛军数据
     *
     * @param player
     */
    private static void handRebelData(Player player) {
        if (player.rebelData != null) {
            player.rebelData.setNick(player.lord.getNick());
            player.rebelData.setKillGuard(0);
            player.rebelData.setKillLeader(0);
            player.rebelData.setKillNum(0);
            player.rebelData.setKillUnit(0);
            player.rebelData.setLastRank(0);
            player.rebelData.setScore(0);
            player.rebelData.setTotalGuard(0);
            player.rebelData.setTotalLeader(0);
            player.rebelData.setTotalScore(0);
            player.rebelData.setTotalUnit(0);
        }
    }

    /**
     * 玩家军事矿区数据处理
     *
     * @param player
     */
    private static void handSenior(Player player) {
        //军事矿区清空
        player.seniorScore = 0;
    }

    /**
     * 清空玩家竞技场邮件
     *
     * @param player
     */
    private static void handArenaMail(Player player) {
        //竞技场邮件全部删掉
        Iterator<NewMail> it = player.getNewMails().iterator();
        while (it.hasNext()) {
            NewMail mail = it.next();
            if (mail.getType() == MailType.ARENA_MAIL || mail.getType() == MailType.ARENA_GLOBAL_MAIL) {
                it.remove();
            }
        }
    }

    /**
     * 如果玩家好友列表中包含有已经被清除的小号玩家，则删除这个好友以及好友的祝福
     *
     * @param player
     * @param totalIds
     */
    private static void handFrind(Player player, Set<Long> totalIds) {
        //好友列表
        if (!player.friends.isEmpty()) {
            HashSet<Long> rmSet = new HashSet<>();
            for (Map.Entry<Long, Friend> entry : player.friends.entrySet()) {
                if (!totalIds.contains(entry.getKey())) {
                    rmSet.add(entry.getKey());
                }
            }
            if (!rmSet.isEmpty()) {
                for (Long id : rmSet) {
                    player.friends.remove(id);
                }
            }
        }

        //好友祝福
        if (!player.blesses.isEmpty()) {
            HashSet<Long> rmSet = new HashSet<>();
            for (Map.Entry<Long, Bless> entry : player.blesses.entrySet()) {
                if (!totalIds.contains(entry.getKey())) {
                    rmSet.add(entry.getKey());
                }
            }
            if (!rmSet.isEmpty()) {
                for (Long id : rmSet) {
                    player.blesses.remove(id);
                }
            }
        }
    }

    private static void addProp(Player player, int propId, int count) {
        Prop prop = player.props.get(propId);
        if (prop != null) {
            prop.setCount(count + prop.getCount());
        } else {
            prop = new Prop(propId, count);
            player.props.put(propId, prop);
        }
    }

    /**
     * 部队全部返还
     **/
    private static void retreatEnd(Player player) {
        Iterator<Army> it = player.armys.iterator();
        while (it.hasNext()) {
            Army army = it.next();
            int state = army.getState();
            if (state == ArmyState.WAR || state == ArmyState.FortessBattle) {
                it.remove();
                retreat(player, army);
                continue;
            }
            if (state == ArmyState.RETREAT || state == ArmyState.MARCH || state == ArmyState.AID) {
                it.remove();
                retreat(player, army);
                continue;
            }
            if (state == ArmyState.COLLECT) {
                it.remove();
                retreat(player, army);
            } else if (state == ArmyState.GUARD || state == ArmyState.WAIT) {// 召回驻防
                it.remove();
                retreat(player, army);
            } else if (army.getState() == ArmyState.AIRSHIP_BEGAIN
                    || army.getState() == ArmyState.AIRSHIP_MARCH
                    || army.getState() == ArmyState.AIRSHIP_GUARD
                    || army.getState() == ArmyState.AIRSHIP_GUARD_MARCH) {
                it.remove();
                retreat(player, army);
            }
        }
    }

    private static void retreat(Player player, Army army) {
        try {
            // 部队返回
            int[] p = army.getForm().p;
            int[] c = army.getForm().c;
            for (int i = 0; i < p.length; i++) {
                if (p[i] > 0 && c[i] > 0) {
                    addTank(player, p[i], c[i], AwardFrom.RETREAT_END);
                }
            }
            // 将领返回
            if (army.getForm().getAwakenHero() != null) {
                AwakenHero awakenHero = player.awakenHeros.get(army.getForm().getAwakenHero().getKeyId());
                if(awakenHero != null ){
                    awakenHero.setUsed(false);
                    LogLordHelper.awakenHero(AwardFrom.RETREAT_END, player.account, player.lord, awakenHero, 0);
                }

            } else {
                int heroId = army.getForm().getCommander();
                if (heroId > 0) {
                    addHero(player, heroId, 1, AwardFrom.RETREAT_END);
                }
            }

            // 加资源
            Grab grab = army.getGrab();
            if (grab != null && player.resource != null) {
                gainGrab(player, grab);
            }
        } catch (Exception e) {
            LogUtil.error(String.format("lordId :%d, retreat army :%s, error ", player.lord.getLordId(), army.toString()), e);
            LogUtil.error("合服报错",e);
            System.exit(-1);
        }
    }

    private static Hero addHero(Player player, int heroId, int count, AwardFrom from) {
        Hero hero = player.heros.get(heroId);
        if (hero != null) {
            hero.setCount(hero.getCount() + count);
            if (count < 0 && hero.getCount() <= 0) {
                player.heros.remove(heroId);
            }
        } else {
            hero = new Hero(heroId, heroId, count);
            player.heros.put(hero.getHeroId(), hero);
        }
        if(player.herosExpiredTime.containsKey(heroId)){
            hero.setEndTime(player.herosExpiredTime.get(heroId));
        }
        return hero;
    }

    private static Tank addTank(Player player, int tankId, int count, AwardFrom from) {
        Tank tank = player.tanks.get(tankId);
        if (tank != null) {
            tank.setCount(count + tank.getCount());
        } else {
            tank = new Tank(tankId, count, 0);
            player.tanks.put(tankId, tank);
        }
        return tank;
    }

    private static void gainGrab(Player target, Grab grab) {
        modifyIron(target, grab.rs[0], AwardFrom.GAIN_GRAB);
        modifyOil(target, grab.rs[1], AwardFrom.GAIN_GRAB);
        modifyCopper(target, grab.rs[2], AwardFrom.GAIN_GRAB);
        modifySilicon(target, grab.rs[3], AwardFrom.GAIN_GRAB);
        modifyStone(target, grab.rs[4], AwardFrom.GAIN_GRAB);
    }

    private static void modifyIron(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settIron(resource.gettIron() + add);
        }
        resource.setIron(resource.getIron() + add);
    }

    private static void modifyOil(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settOil(resource.gettOil() + add);
        }
        resource.setOil(resource.getOil() + add);
    }

    private static void modifyCopper(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settCopper(resource.gettCopper() + add);
        }
        resource.setCopper(resource.getCopper() + add);
    }

    private static void modifySilicon(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settSilicon(resource.gettSilicon() + add);
        }
        resource.setSilicon(resource.getSilicon() + add);
    }

    private static void modifyStone(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settStone(resource.gettStone() + add);
        }
        resource.setStone(resource.getStone() + add);
    }

    private static Effect addEffect(Player player, int id, int time) {
        int nowSec = TimeHelper.getCurrentSecond();
        Effect effect = player.effects.get(id);
        if (effect != null) {
            effect.setEndTime(Math.max(effect.getEndTime(), nowSec) + time);
        } else {
            effect = new Effect(id, nowSec + time);
            player.effects.put(id, effect);
        }

//        LogUtil.error(String.format("lordId :%d, nick :%s 获得合服保护罩, 保护罩结束时间：%s", player.lord.getLordId(), player.lord.getNick(), DateHelper.formatDateMiniTime(new Date(effect.getEndTime() * 1000L))));
        return effect;
    }


}
