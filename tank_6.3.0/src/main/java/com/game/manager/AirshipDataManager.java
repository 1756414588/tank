package com.game.manager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.AirshipConst;
import com.game.constant.ArmyState;
import com.game.constant.AwardFrom;
import com.game.constant.MailType;
import com.game.constant.PartyType;
import com.game.constant.PropId;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticTankDataMgr;
import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.l.PartyJobFree;
import com.game.domain.p.Army;
import com.game.domain.p.Guard;
import com.game.domain.p.March;
import com.game.domain.p.airship.Airship;
import com.game.domain.p.airship.AirshipGuard;
import com.game.domain.p.airship.AirshipTeam;
import com.game.domain.p.airship.PlayerAirship;
import com.game.domain.s.StaticAirship;
import com.game.domain.s.StaticTank;
import com.game.domain.sort.MemberAirshipSort;
import com.game.util.LogUtil;
import com.game.util.MapHelper;
import com.game.util.StcHelper;
import com.game.util.TimeHelper;
import com.game.util.Tuple;
/**
* @ClassName: AirshipDataManager 
* @Description: 飞艇数据处理
* @author
 */
@Component
public class AirshipDataManager {
    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    public void init() {

    }

    /**
    * @Title: getAirshipMap 
    * @Description: 根据编号获得飞艇对象
    * @return  
    * Map<Integer,Airship>   

     */
    public Map<Integer, Airship> getAirshipMap() {
        return globalDataManager.gameGlobal.getAirshipMap();
    }

    /**
     * 飞艇功能首次加入地图
     */
    public boolean firstLoadAirship() throws Exception {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return false;
        Map<Integer, Airship> airshipMap = getAirshipMap();

        Map<Integer, List<Airship>> waitOpenAirshipMap = new HashMap<>();

        Set<Player> needMovePlayer = new HashSet<>();
        for (StaticAirship sap : staticWorldDataMgr.getAirshipMap().values()) {
            List<Integer> nearPos = new ArrayList<>();
            //此坐标周围四个点是否为空
            boolean canLoadAirship = xyCanLoadAirship(sap.getPos(), nearPos);
            if (!canLoadAirship) {
                throw new Exception("无法载入飞艇");
            }

            for (int pos : nearPos) {
                Player player = worldDataManager.getPosData(pos);
                if (player != null) {
                    needMovePlayer.add(player);
                }
            }
            List<Integer> openTime = sap.getOpenTime();

            Airship airship = new Airship();
            airship.setId(sap.getId());
            if (airshipMap.containsKey(sap.getId())) {
                airship = airshipMap.get(sap.getId());
            } else {
                int safeEndTime = 0;
                if (openTime.get(0) == 1) {//多少天之后开启
                    safeEndTime = TimeHelper.getAirshipOpenTime(openTime.get(1));
                } else if (openTime.get(0) == 2) {//哪个飞艇被打占领之后开启
                    safeEndTime = -1;
                }
                airship.setSafeEndTime(safeEndTime);
                airship.setDurability(AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX);
            }

            if (openTime.get(0) == 2 && airship.getSafeEndTime() == -1) {
                int id = openTime.get(1);
                List<Airship> airships = waitOpenAirshipMap.get(id);
                if (airships == null) {
                    airships = new ArrayList<>();
                    waitOpenAirshipMap.put(id, airships);
                }
                airships.add(airship);
            }

            worldDataManager.setAirship(nearPos, airship);
            airshipMap.put(airship.getId(), airship);

            iniAirshipFightDefault(sap);
        }

        int nowSec = TimeHelper.getCurrentSecond();
        for (Player player : needMovePlayer) {
            int pos = player.lord.getPos();
            int newPos = worldDataManager.randomEmptyPos();
            LogUtil.error("飞艇位置，强制转移玩家：lordId= " + player.lord.getLordId() + "," + player.lord.getPos() + " -> " + newPos);
            playerDataManager.addProp(player, PropId.MOVE_HOME_1, 1, AwardFrom.REPAIR_NAME);
            playerDataManager.sendNormalMail(player, MailType.MOLD_AIRSHIP_PLAYER_POS, nowSec, String.valueOf(player.lord.getPos()));
            player.lord.setPos(newPos);
            //行军中的玩家,修改目的地
            List<March> marchList = worldDataManager.getMarch(pos);
            if (marchList != null) {
                for (March march : marchList) {
                    march.getArmy().setTarget(newPos);
                    worldDataManager.addMarch(march);
                }
            }
            //基地驻军 复制别人的 moveHome
            List<Guard> list = worldDataManager.getGuard(pos);
            if (list != null) {
                for (int i = 0; i < list.size(); i++) {
                    Guard guard = list.get(i);
                    guard.getArmy().setTarget(newPos);
                    worldDataManager.setGuard(guard);
                }
            }

            worldDataManager.removeGuard(pos);
            worldDataManager.removePosPlayer(pos);//被转移说明飞艇占用 所以不额外增加空闲位置
        }

        Map<String, Army> playerAirshipArmyMap = new HashMap<>();
        Set<PartyData> partyDataSet = new HashSet<>();

        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                continue;
            }

            PartyData partyData = partyDataManager.getPartyByLordId(player.roleId);

            List<Army> list = player.armys;
            Iterator<Army> itArmy = list.iterator();

            while (itArmy.hasNext()) {
                Army army = itArmy.next();
                if (army.getState() == ArmyState.AIRSHIP_BEGAIN
                        || army.getState() == ArmyState.AIRSHIP_MARCH
                        || army.getState() == ArmyState.AIRSHIP_GUARD
                        || army.getState() == ArmyState.AIRSHIP_GUARD_MARCH) {
                    army.player = player;
                    playerAirshipArmyMap.put(player.roleId + "_" + army.getKeyId(), army);
                    if (partyData == null) {
                        LogUtil.error("玩家部队飞艇部队信息异常,没有军团了。" + player.roleId);
                    } else {
                        partyDataSet.add(partyData);
                    }
                }
            }
        }

        //关联部队信息
        for (PartyData partyData : partyDataSet) {
            for (AirshipTeam team : partyData.getAirshipTeamMap().values()) {
                Iterator<Long[]> iter = team.getArmysDb().iterator();
                while (iter.hasNext()) {
                    Long[] armyDb = iter.next();
                    Army army = playerAirshipArmyMap.get(armyDb[0] + "_" + armyDb[1]);
                    if (army == null) {
                        LogUtil.error("飞艇组队信息异常,部队没有了。" + team.getLordId() + "," + armyDb[0] + "_" + armyDb[1]);
                        iter.remove();
                        continue;
                    }
                    team.getArmys().add(army);
                }
                getTeamArmyMap(team.getId()).add(team);
            }
            for (AirshipGuard guard : partyData.getAirshipGuardMap().values()) {
                Iterator<Long[]> iter = guard.getArmysDb().iterator();
                while (iter.hasNext()) {
                    Long[] armyDb = iter.next();
                    Army army = playerAirshipArmyMap.get(armyDb[0] + "_" + armyDb[1]);
                    if (army == null) {
                        LogUtil.error("飞艇驻军信息异常,部队没有了。" + guard.getId() + "," + armyDb[0] + "_" + armyDb[1]);
                        iter.remove();
                        continue;
                    }
                    guard.getArmys().add(army);
                    putGuardArmy(guard.getId(), army);
                }
            }
        }

        for (Airship airship : getAirshipMap().values()) {
            airship.waitOpenAirship = waitOpenAirshipMap.get(airship.getId());
            PartyData partyData = partyDataManager.getParty(airship.getPartyId());
            if (partyData != null) {
                airship.setPartyData(partyData);
            }
        }

        return true;
    }

    /**
     * 此坐标点周围是否能加入飞艇
     */
    private boolean xyCanLoadAirship(int initPos, List<Integer> nearPos) {
        Tuple<Integer, Integer> t = MapHelper.reducePos(initPos);
        int[] xy = new int[]{t.getA(), t.getB()};
        boolean canLoadAirship = true;
        int x = 0;
        int y = 0;
        //一个飞艇占用四个点
        for (int i = 1; i <= 4; i++) {
            switch (i) {
                case 1:
                    x = xy[0];
                    y = xy[1];
                    break;
                case 2:
                    x = xy[0] + 1;
                    y = xy[1];
                    break;
                case 3:
                    x = xy[0];
                    y = xy[1] + 1;
                    break;
                case 4:
                    x = xy[0] + 1;
                    y = xy[1] + 1;
                    break;
            }
            int pos = WorldDataManager.pos(x, y);
            canLoadAirship &= isValidPos(pos, x, y);
            nearPos.add(pos);
        }
        return canLoadAirship;
    }

    /**
     * 加载飞艇到世界地图
     */
    private boolean isValidPos(int pos, int x, int y) {
        if (!worldDataManager.isValidPos(pos)) {
            LogUtil.error("飞艇坐标配置错误,坐标不和规范," + "x=" + x + " y=" + y);
            return false;
        }

        if (worldDataManager.isRebel(pos)) {
            LogUtil.error("飞艇坐标配置错误,叛军坐标，生成叛军代码没改时绝对不会出现。" + "x=" + x + " y=" + y);
            return false;
        }

        if (worldDataManager.isActRebel(pos)) {
            LogUtil.error("飞艇坐标配置错误，生成剿匪代码没改时绝对不会出现。" + "x=" + x + " y=" + y);
            return false;
        }

        if (worldDataManager.isAirship(pos)) {
            LogUtil.error("飞艇坐标配置错误,飞艇重复。" + "x=" + x + " y=" + y);
            return false;
        }

        if (worldDataManager.evaluatePos(pos) != null) {
            LogUtil.error("飞艇出现在资源点上，" + "x=" + x + " y=" + y);
            return false;
        }

        return true;
    }

    /**
    * @Title: getMyAirshipArmyCount 
    * @Description: 玩家飞艇部队数量
    * @param player
    * @param partyData
    * @return  
    * int   

     */
    public int getMyAirshipArmyCount(Player player, PartyData partyData) {
        int count = 0;
        if (partyData != null) {
            List<Army> list = player.armys;
            Iterator<Army> it = list.iterator();
            while (it.hasNext()) {
                Army army = it.next();
                if (army.getState() == ArmyState.AIRSHIP_BEGAIN
                        || army.getState() == ArmyState.AIRSHIP_MARCH
                        || army.getState() == ArmyState.AIRSHIP_GUARD_MARCH
                        || army.getState() == ArmyState.AIRSHIP_GUARD) {
                    count++;
                }
            }
        }
        return count;
    }

    /**
     * 当玩家离开军团时:<br>
     * 1.正在驻防的部队<br>
     * 2.正在行军中的驻防部队<br>
     * 3.进攻集结队伍中的部队<br>
     * 4.此方法还将撤回进攻集结行军中的部队, 事实上如果玩家如果有进攻行军中的部队,
     * 是不允许离开军团的, 请在调用此方法前判断, 此处处理完全是为了防止出现异常数据
     * 都需要撤回
     *
     * @param player
     * @param partyData 退出前的军团
     */
    public void afterQuitParty(Player player, PartyData partyData) {
        try {
            int nowSec = TimeHelper.getCurrentSecond();
            Iterator<Army> armyIter = player.armys.iterator();
            while (armyIter.hasNext()) {
                Army army = armyIter.next();
                int state = army.getState();//玩家部队状态
                Airship airship = null;
                if (state == ArmyState.AIRSHIP_GUARD
                        || state == ArmyState.AIRSHIP_GUARD_MARCH) {
                    airship = getAirshipByArmy(army);
                    //撤回驻军与驻军行军中的部队
                    retreatGuardArmy(army, nowSec, airship);
                } else if (state == ArmyState.AIRSHIP_BEGAIN) {
                    airship = getAirshipByArmy(army);
                    //撤回集结准备中的部队
                    retreatTeamBegainArmy(army, nowSec);
                    //撤回后处理
                    afterRetreatTeamArmy(army, airship, partyData, state, nowSec);
                } else if (state == ArmyState.AIRSHIP_MARCH) {
                    //正常逻辑是不会执行到此代码块的
                    LogUtil.error(String.format("nick :%s, quit party id :%d, but has march army", player.lord.getNick(), partyData.getPartyId()));
                    airship = getAirshipByArmy(army);
                    //撤回行军中的部队
                    retreatTeamMarchArmy(army, nowSec);
                    //撤回后处理
                    afterRetreatTeamArmy(army, airship, partyData, state, nowSec);
                }

            }
        } catch (Exception e) {
            LogUtil.error("", e);
        }

    }

    /**
    * @Title: getAirshipByArmy 
    * @Description: 取得部队的攻击目标飞艇
    * @param army
    * @return  
    * Airship   

     */
    public Airship getAirshipByArmy(Army army){
        StaticAirship staticAirship = staticWorldDataMgr.getStaticAirshipByPos(army.getTarget());
        return staticAirship != null ? getAirshipMap().get(staticAirship.getId()) : null;
    }

    /**
     * 撤回组队(准备|行军)中的部队后处理逻辑
     * @param army
     * @param airship
     * @param partyData
     * @param armyState
     * @param nowSec
     */
    public void afterRetreatTeamArmy(Army army, Airship airship, PartyData partyData, int armyState, int nowSec) {
        //准备状态中的战事(队伍)部队为空时不做处理，工会不能重新创建对此飞艇的战事，但是可以加入此战事
        AirshipTeam team = partyData != null ? partyData.getAirshipTeamMap().get(airship.getId()) : null;
        if (team != null) {
            team.getArmys().remove(army);
            if (team.getArmys().size() == 0) {
                if (armyState == ArmyState.AIRSHIP_MARCH) {
                    //行军中的战事(队伍)部队为空时自动取消战事(队伍)，工会可重新创建对此飞艇的战事
                    teamCancel(airship, team, partyData, nowSec, AirshipConst.AIRSHIP_ATTACK_RETREAT_SECOND, true);
                }else{
                    StcHelper.syncAirshipTeamChange2Party(partyData.getPartyId(), airship.getId(), AirshipConst.TEAM_STATUS_UPDATE);
                }
            } else {
                StcHelper.syncAirshipTeamChange2Party(partyData.getPartyId(), airship.getId(), AirshipConst.TEAM_STATUS_UPDATE);
            }
        }
        StcHelper.syncAirshipTeamArmy2Player(army.player, AirshipConst.TEAM_STATE_ARMY_CHANGE);
    }

    /**
     * 处理撤回驻军与驻军行军部队后的事情
     * @param army
     * @param airship
     */
    public void afterRetreatGuardArmy(Army army, Airship airship){
        List<Army> guardArmys = airship.getGuardArmy();
        if (guardArmys != null) {
            guardArmys.remove(army);
        }
        PartyData partyData = airship.getPartyData();
        if (partyData != null) {
            AirshipGuard guard = partyData.getAirshipGuardMap().get(airship.getId());
            if (guard != null) {
                guard.getArmys().remove(army);
            }
        }
        StcHelper.syncAirshipTeamArmy2Player(army.player, AirshipConst.TEAM_STATE_ARMY_CHANGE);
    }

    /**
    * @Title: removeTeam 
    * @Description: 
    * @param team
    * @param partyData  
    * void   

     */
    public void removeTeam(AirshipTeam team, PartyData partyData) {
        List<AirshipTeam> teams = getTeamArmyMap(team.getId());
        if (teams != null) {
            teams.remove(team);
        }
    }

    public AirshipTeam getMyTeam(long roleId, PartyData partyData) {
        for (AirshipTeam team : partyData.getAirshipTeamMap().values()) {
            if (team.getLordId() == roleId) {
                return team;
            }
        }
        return null;
    }

    public List<Army> getMyArmy(long roleId, AirshipTeam team) {
        List<Army> list = new ArrayList<>();
        for (Army army : team.getArmys()) {
            if (army.player.roleId == roleId) {
                list.add(army);
            }
        }
        return list;
    }

    public Army getMyArmy(long roleId, int armyKeyId, AirshipTeam team) {
        for (Army army : team.getArmys()) {
            if (army.player.roleId == roleId && army.getKeyId() == armyKeyId) {
                return army;
            }
        }
        return null;
    }

    /**
     * 获取指向某个飞艇的行军队伍数量
     *
     * @param airshipId
     * @return
     */
    public int getMarchTeamCount(int airshipId) {
        List<AirshipTeam> teams = getTeamArmyMap(airshipId);
        if (teams == null) {
            return 0;
        }
        int count = 0;
        for (AirshipTeam team : teams) {
            if (team.getState() == ArmyState.AIRSHIP_MARCH) {
                count++;
            }
        }
        return count;
    }

    /**
    * @Title: getTeamArmyMap 
    * @Description:  根据id获得飞艇的部队
    * @param id
    * @return  
    * List<AirshipTeam>   

     */
    public List<AirshipTeam> getTeamArmyMap(int id) {
        return getAirshipMap().get(id).getTeamArmy();
    }

    /**
     * 撤回进攻飞艇队伍
     *
     * @param team      进攻飞艇的队伍
     * @param partyData
     * @param now
     * @param period    撤回所需时间
     */
    public void teamCancel(Airship airship, AirshipTeam team, PartyData partyData, int now, int period, boolean notifyWorld) {
        int endTime = now + period;
        team.setState(ArmyState.RETREAT);
        team.setEndTime(endTime);
        Set<Player> playerSet = new HashSet<>();
        for (Army army : team.getArmys()) {
            army.setState(team.getState());
            //如果部队中没有坦克则立即返回部队
            army.setPeriod(army.hasTank() ? period : 0);
            army.setEndTime(army.hasTank() ? endTime : now);
            playerSet.add(army.player);
        }

        //通知队伍中设置了部队的玩家更新部队状态
        for (Player player : playerSet) {
            StcHelper.syncAirshipTeamArmy2Player(player, AirshipConst.TEAM_STATE_ARMY_CHANGE);
        }

        if (partyData != null) {
            //删除军团中指定的进攻队伍
            partyData.getAirshipTeamMap().remove(team.getId());
            //通知工会玩家进攻飞艇的队伍被删除了
            StcHelper.syncAirshipTeamChange2Party(partyData.getPartyId(), airship.getId(), AirshipConst.TEAM_STATUS_DELETE);
        }

        //通知全服玩家飞艇(被攻击)的状态变化
        if (notifyWorld) {
            StcHelper.syncAirshipChange2World(airship.getId());
        }
    }

    /**
     * 队伍状态发生变化
     *
     * @param team
     * @param period
     */
    public void teamStateChange(AirshipTeam team, int period) {
        Set<Player> playerSet = new HashSet<>();
        for (Army army : team.getArmys()) {
            army.setState(team.getState());
            army.setEndTime(team.getEndTime());
            army.setPeriod(period);
            playerSet.add(army.player);
        }

        for (Player player : playerSet) {
            StcHelper.syncAirshipTeamArmy2Player(player, AirshipConst.TEAM_STATE_ARMY_CHANGE);
        }
    }

    /**
    * @Title: putGuardArmy 
    * @Description: 往飞艇防守部队中添加部队
    * @param id
    * @param army  
    * void   

     */
    public void putGuardArmy(int id, Army army) {
        List<Army> armys = getAirshipMap().get(id).getGuardArmy();
        armys.add(army);
    }

    /**
    * @Title: getGuardArmyMap 
    * @Description: 得到飞艇防守部队
    * @param id
    * @return  
    * List<Army>   

     */
    public List<Army> getGuardArmyMap(int id) {
        return getAirshipMap().get(id).getGuardArmy();
    }

    public void retreatTeamBegainArmy(Army army, int now) {
        int period = 0;
        army.setState(ArmyState.RETREAT);
        army.setEndTime(now + period);
        army.setPeriod(period);
    }

    public void retreatTeamMarchArmy(Army army, int now) {
        int period = AirshipConst.AIRSHIP_ATTACK_RETREAT_SECOND;
        army.setState(ArmyState.RETREAT);
        army.setEndTime(now + period);
        army.setPeriod(period);
    }

    public void retreatGuardArmy(Army army, int now, Airship airship) {
        int period = army.hasTank() ? AirshipConst.AIRSHIP_GUARD_RETREAT_SECOND : 0;
        army.setState(ArmyState.RETREAT);
        army.setEndTime(now + period);
        army.setPeriod(period);
        //撤回驻军部队与驻军行军部队后
        afterRetreatGuardArmy(army, airship);
    }

    /**
     * 自动设置飞艇指挥官
     */
    public boolean autoSetAirshipLeader(Airship airship, PartyData partyData, Player teamPlayer) {
        //如果队长未拥有飞艇，则分配给其他成员
        boolean hasAirship = false;
        Map<Integer, Long> airshipLeaderMap = partyData.getAirshipLeaderMap();
        for (Entry<Integer, Long> entry : airshipLeaderMap.entrySet()) {
            if (entry.getValue().intValue() == teamPlayer.roleId) {
                hasAirship = true;
                break;
            }
        }
        Long leaderLordId = null;
        if (hasAirship) {
            leaderLordId = teamPlayer.roleId;
        } else {//分配给其他成员
            for (Member member : partyDataManager.getMemberListOrderByJob(partyData.getPartyId())) {
                if (!airshipLeaderMap.values().contains(member.getLordId())) {
                    leaderLordId = member.getLordId();
                    break;
                }
            }
        }

        //如果没有其他成员分配则不能占领
        if (leaderLordId == null) {
            return false;
        }
        airshipLeaderMap.put(airship.getId(), leaderLordId);
        return true;
    }

    /**
     * 自动任命一个指挥官
     *
     * @param party
     * @param teamLeader
     * @return NULL 任命飞艇指挥官失败
     */
    public Member autoAppointCommander(Airship airship, PartyData party, Player teamLeader) {
        Member airshipCmd = null;
        if (teamLeader != null && !partyDataManager.hasAirship(party, teamLeader)) {
            airshipCmd = partyDataManager.getMemberById(teamLeader.lord.getLordId());
        } else {
            airshipCmd = pickAirshipCommander(party);
        }

        if (airshipCmd != null) {
            party.getAirshipLeaderMap().put(airship.getId(), airshipCmd.getLordId());
            //世界频道广播任命信息
            StcHelper.syncAirshipChange2World(airship.getId());
        }
        return airshipCmd;
    }

    /**
     * 从工会中选出一个成员做飞艇指挥官, null:没有符合条件的成员
     *
     * @param party
     * @return
     */
    private Member pickAirshipCommander(PartyData party) {
        List<MemberAirshipSort> sorts = partyDataManager.sortAndReturnAirshipList(party);
        for (MemberAirshipSort sort : sorts) {
            Player player = playerDataManager.getPlayer(sort.getLordId());
            if (!partyDataManager.hasAirship(party, player)) {
                return partyDataManager.getMemberById(sort.getLordId());
            }
        }
        return null;
    }


    /**
     * 道具生产
     *
     * @param airship
     * @param now     当前时间
     */
    public void produceItem(Airship airship, int now) {
        //飞艇处于废墟状态,或者未被占领状态,都不能生产资源
        if (airship.isRuins() || airship.getPartyData() == null) return;
        StaticAirship sap = staticWorldDataMgr.getAirshipMap().get(airship.getId());
        int beforeProduceNum = airship.getProduceNum();
        if (beforeProduceNum >= sap.getCapacity()) {
            return;//已经达到飞艇容量上限
        }

        int subTime = now - airship.getProduceTime();
        if (subTime < sap.getEfficiency()) {
            return;//生产时间不足
        }

        int addNum = subTime / sap.getEfficiency();
        if (beforeProduceNum + addNum >= sap.getCapacity()) {
            addNum = sap.getCapacity() - beforeProduceNum;
        }
        airship.setProduceNum(beforeProduceNum + addNum);
        airship.setProduceTime(now - (subTime % sap.getEfficiency()));
    }

    /**
     * 检测并系统回收飞艇
     *
     * @param airship
     * @param nowSec
     */
    public void checkAndRecoveryAirship(StaticAirship stp, Airship airship, int nowSec) {
        if (airship.isRuins() && airship.getOccupyTime() + AirshipConst.AIRSHIP_SAFE_TIME < nowSec) {
            //飞艇占领后默认加的保护罩时间已过, 但飞艇仍然处于废墟状态,此时飞艇将被系统回收至中立状态
            clearAirshipData2Npc(stp, airship);
            //通知全服飞艇变更
            StcHelper.syncAirshipChange2World(airship.getId());
        }
    }

    /**
    * @Title: clearAirshipData2Npc 
    * @Description: 清除NPC飞艇数据
    * @param stp
    * @param airship  
    * void   

     */
    public void clearAirshipData2Npc(StaticAirship stp, Airship airship) {
        airship.setProduceTime(0);
        airship.setProduceNum(0);
        airship.setFight(stp.getFight());

        //清除飞艇占领时间
        airship.setOccupyTime(0);
        //清除飞艇保护时间
        airship.setSafeEndTime(0);
        //中立状态的飞艇不属于废墟
        airship.setRuins(false);
        //设置飞艇的耐久度满
        airship.setDurability(AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX);
        //清除飞艇军团信息
        PartyData partyData = airship.getPartyData();
        if (partyData != null) {
            partyData.getAirshipGuardMap().remove(airship.getId());
            partyData.getAirshipLeaderMap().remove(airship.getId());
            airship.getGuardArmy().clear();
        }
        //清除飞艇的占领军团
        airship.setPartyData(null);

        //清除征收记录
        airship.getRecvRecordList().clear();
    }

    /**
    * @Title: clearAirshipData2Party 
    * @Description: 清除飞艇NPC数据
    * @param stp
    * @param airship
    * @param partyData
    * @param nowSec  
    * void   

     */
    public void clearAirshipData2Party(StaticAirship stp, Airship airship, PartyData partyData, int nowSec) {
        airship.setProduceTime(0);
        airship.setProduceNum(0);
        airship.setFight(stp.getFight());

        //飞艇给玩家
        //设置飞艇占领时间
        airship.setOccupyTime(nowSec);
        //设置飞艇保护时间
        airship.setSafeEndTime(nowSec + AirshipConst.AIRSHIP_SAFE_TIME);
        //设置飞艇为废墟状态
        airship.setRuins(true);
        //设置飞艇归属
        airship.setPartyData(partyData);
        //清除飞艇耐久度
        airship.setDurability(0);
        
        //清除征收记录
        airship.getRecvRecordList().clear();
    }

    /**
     * 检测并开放新飞艇
     *
     * @param airship
     */
    public void checkAndOpenAirship(Airship airship) {
        //开放新的飞艇
        if (airship.waitOpenAirship != null) {
            for (Airship a : airship.waitOpenAirship) {
                a.setSafeEndTime(0);
            }
            airship.waitOpenAirship = null;
        }
    }

    /**
     * 初始化飞艇的默认战力
     *
     * @param stp
     */
    private void iniAirshipFightDefault(StaticAirship stp) {
        List<Integer> armys = stp.getArmy();
        StaticTank staticTank = staticTankDataMgr.getStaticTank(armys.get(0));
        stp.setFight(staticTank.getFight() * armys.get(1));
    }

    /**
     * 获取玩家
     *
     * @param airship
     * @param player
     * @param partyData
     * @param job
     * @param nowDay
     * @return
     */
    public int getPlayerFreeCrtTeamCnt(Airship airship, Player player, PartyData partyData, int job, int nowDay) {
        int freeCnt = 0;
        if (job == PartyType.LEGATUS || job == PartyType.LEGATUS_CP) {
            //判断个人今天是否已经使用过免费次数
            PlayerAirship playerAirship = getPlayerAirshipMap().get(player.roleId);
            boolean isToday = playerAirship != null && playerAirship.getFreeCrtDay() == nowDay;
            freeCnt = AirshipConst.AIRSHIP_FREE_CREATE_TEAM_COUNT - (isToday ? playerAirship.getFreeCrtCount() : 0);
            if (freeCnt > 0) {
                //军团长和副军团长这个职位一天只能免费创建一次
                PartyJobFree jobFree = partyData.getFreeMap().get(job);
                isToday = jobFree != null && jobFree.getFreeDay() == nowDay;
                int max_free_count = job == PartyType.LEGATUS ? 1 : PartyType.LEGATUS_CP_MAX_COUNT;
                int partyFreeCnt = max_free_count - (isToday ? jobFree.getFree() : 0);
                freeCnt = Math.min(freeCnt, partyFreeCnt);
            }
        }
        return freeCnt;
    }

    /**
    * @Title: getPlayerAirshipMap 
    * @Description: 玩家飞艇MAP
    * @return  
    * Map<Long,PlayerAirship>   

     */
    public Map<Long, PlayerAirship> getPlayerAirshipMap() {
        return globalDataManager.gameGlobal.getPlayerAirshipMap();
    }

}
