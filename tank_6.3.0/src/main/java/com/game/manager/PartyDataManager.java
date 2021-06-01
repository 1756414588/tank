package com.game.manager;

import com.game.common.ServerSetting;
import com.game.constant.ActivityConst;
import com.game.constant.PartyType;
import com.game.constant.WarState;
import com.game.dao.impl.p.PartyDao;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticPartyDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticActAward;
import com.game.domain.s.StaticPartyProp;
import com.game.domain.s.StaticPartyTrend;
import com.game.domain.sort.MemberAirshipSort;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import com.google.protobuf.InvalidProtocolBufferException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-9 下午4:05:25
 * @declare 军团相关数据处理
 */
@Component
public class PartyDataManager {
	@Autowired
	private PartyDao partyDao;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private StaticPartyDataMgr staticPartyDataMgr;

	@Autowired
	private GlobalDataManager globalDataManager;

	@Autowired
	private SmallIdManager smallIdManager;

	@Autowired
	private ServerSetting serverSetting;

    @Autowired
    private RankDataManager rankDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;
    @Autowired
    private ActivityDataManager activityDataManager;

    /**key: 军团编号*/
	private Map<Integer, PartyData> partyMap = new HashMap<Integer, PartyData>();
	 /**key: 军团名称*/
	private Map<String, PartyData> partyNameMap = new HashMap<>();
	/**军团排行列表*/
	private List<PartyRank> partyRanks = new ArrayList<PartyRank>();
	/**key: 角色lordid*/
	private Map<Long, Member> memberMap = new HashMap<>();
	/**key: 军团id*/
	private Map<Integer, List<Member>> partyMembers = new HashMap<Integer, List<Member>>();

	// 记录小号的军团成员
	private List<PartyMember> smallIdPartyMembers = new ArrayList<>();
	// 记录有小号的军团
	private Set<Integer> smallIdPartys = new HashSet<Integer>();

    private AtomicInteger maxPartyIdInThisServer = new AtomicInteger();
    //一个服务器最多创建的军团个数(MAX_PARTY_ID_FLAG -1)
    public static final int MAX_PARTY_ID_FLAG = 100000;


	//	@PostConstruct
	public void init() {
		List<Party> partyList = partyDao.selectParyList();
		List<PartyMember> partyMemberList = partyDao.selectParyMemberList();
		for (PartyMember e : partyMemberList) {
			if (e == null) {
				continue;
			}

			if(smallIdManager.isSmallId(e.getLordId())){
				// 若是小号,记录下来先
				smallIdPartyMembers.add(e);
				smallIdPartys.add(e.getPartyId());
				continue;
			}

			Member member = new Member();
			try {
				member.loadMember(e);
			} catch (InvalidProtocolBufferException e1) {
				e1.printStackTrace();
			}

			memberMap.put(e.getLordId(), member);

			int partyId = e.getPartyId();
			if (partyId != 0) {
				List<Member> list = partyMembers.get(partyId);
				if (list == null) {
					list = new ArrayList<>();
					partyMembers.put(partyId, list);
				}
				list.add(member);
			}
		}

		// 处理小号
		dealSmallIdPartyMember();

		int rank = 1;
		for (Party e : partyList) {
			List<Member> list = partyMembers.get(e.getPartyId());
			// 说明军团都是小号组成,不加入
			if (smallIdPartys.contains(e.getPartyId()) && (list == null || list.size() == 0)) {
				continue;
			}
			PartyData partyData = new PartyData(e);
			partyMap.put(e.getPartyId(), partyData);
			partyNameMap.put(e.getPartyName(), partyData);

			PartyRank partyRank = new PartyRank(e);
			partyRank.setRank(rank++);

			partyRanks.add(partyRank);
		}

		loadPartyLvRankActivity();

        //初始化本服已经创建过的最大军团ID
        int maxPartyId = partyDao.selectMaxPartyIdInThisServer(MAX_PARTY_ID_FLAG);
        maxPartyIdInThisServer.set(maxPartyId);

	}
	/**
	* @Description:   加载军团等级排行活动
	* void
	 */
	private void loadPartyLvRankActivity() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RANK_PARTY_LV);
        if (activityBase == null) return;
        if (activityBase.getStep() == ActivityConst.OPEN_AWARD){
            int begin = TimeHelper.getDay(activityBase.getBeginTime());
            int end = TimeHelper.getDay(activityBase.getEndTime());
            Map<Integer, PartyLvRank> lvRankMap = new TreeMap<>();
            for (Map.Entry<Integer, PartyData> entry : partyMap.entrySet()) {
                PartyData partyData = entry.getValue();
                Activity activity = partyData.getActivitys().get(ActivityConst.ACT_RANK_PARTY_LV);
                if (activity == null
                        || activity.getStatusList().size() != 5
                        || activity.getBeginTime() != begin
                        || activity.getEndTime() != end) {
                    continue;
                }
                int rank = activity.getStatusList().get(0).intValue();
                int partyLv = activity.getStatusList().get(1).intValue();
                int scienceLv = activity.getStatusList().get(2).intValue();
                int wealLv = activity.getStatusList().get(3).intValue();
                int build = activity.getStatusList().get(4).intValue();
                PartyLvRank partyLvRank = new PartyLvRank(partyData.getPartyId(), partyData.getPartyName(), partyLv, scienceLv, wealLv, build);
                partyLvRank.setRank(rank);
                lvRankMap.put(partyLvRank.getRank(), partyLvRank);
            }
            LinkedList<PartyLvRank> list = rankDataManager.partyLvRankList.getList();
            rankDataManager.partyLvRankList.getList().clear();
            for (Map.Entry<Integer, PartyLvRank> entry : lvRankMap.entrySet()) {
                list.add(entry.getValue());
            }
        }
    }

	/**   处理小号
	* Method: dealSmallIdPartyMember
	* @Description: 判断是否军团长,若不是无所谓<br>
	* 若是军团长,单人的无所谓。 多人的移交给副军团长
	* @return void

	*/
	private void dealSmallIdPartyMember() {
		for (PartyMember partyMember : smallIdPartyMembers) {
			// 若是军团长
			if (partyMember.getJob() == PartyType.LEGATUS) {
				// 获取军团人数
				List<Member> list = 	partyMembers.get(partyMember.getPartyId());
				if(list!=null&&list.size()>0) {
					// 移交给军团长自动移交至副军团长中贡献最高的，若没副军团长则移交至贡献最高的成员
					Collections.sort(list, new Comparator<Member>() {
						public int compare(Member o1, Member o2) {
							if(o1.getJob()>o2.getJob()){
								return 1;
							}else if(o1.getJob() ==o2.getJob()) {
								return o1.getDonate()-o2.getDonate();
							}else {
								return -1;
							}
						}
					});

					Member m = list.get(list.size()-1);
					m.setJob(PartyType.LEGATUS);
				}
			}
		}
	}

    /**
     * 是否拥有飞艇
     * @param partyData
     * @param player
     * @return
     */
    public boolean hasAirship(PartyData partyData, Player player) {
        Map<Integer, Long> airshipLeaderMap = partyData.getAirshipLeaderMap();
        if (!airshipLeaderMap.isEmpty()) {
            for (Map.Entry<Integer, Long> entry : airshipLeaderMap.entrySet()) {
                if (entry.getValue() == player.lord.getLordId()) {
                    return true;
                }
            }
        }
        return false;
    }


    /**
     * 返回按照飞艇归属权排序的成员列表<br>
     * 职务-->军衔-->战力-->贡献-->lord_id
     * @param party
     * @return
     */
    public List<MemberAirshipSort> sortAndReturnAirshipList(PartyData party){
        List<MemberAirshipSort> sorts = new ArrayList<>();
        List<Member> list = partyMembers.get(party.getPartyId());
        for (Member m : list) {
            Player p = playerDataManager.getPlayer(m.getLordId());
            sorts.add(new MemberAirshipSort(m.getJob(), p.lord.getRanks(), p.lord.getFight(), m.getDonate(), p.lord.getLordId()));
        }
        Collections.sort(sorts);
        return sorts;
    }

	public Map<Long, Member> getMemberMap() {
		return memberMap;
	}

	public void setMemberMap(Map<Long, Member> memberMap) {
		this.memberMap = memberMap;
	}

	public PartyData getParty(int partyId) {
		return partyMap.get(partyId);
	}

	public PartyData getParty(String partyName) {
	    return partyNameMap.get(partyName);
	}

	/**
	* @Description: 根据角色id得到所在军团
	* @param lordId
	* @return  
	* PartyData
	 */
	public PartyData getPartyByLordId(long lordId) {
		Member member = memberMap.get(lordId);
		if (member != null) {
			return partyMap.get(member.getPartyId());
		}
		return null;
	}

	/**
	* @Description: 得到玩家军团id
	* @param lordId 角色id
	* @return  
	* int
	 */
	public int getPartyId(long lordId) {
		Member member = memberMap.get(lordId);
		if (member != null) {
			return member.getPartyId();
		} else
			return 0;
	}

	/**
	* @Description: 判断俩玩家是不是同一个军团
	* @param lordId1 
	* @param lordId2
	* @return  
	* boolean
	 */
	public boolean isSameParty(long lordId1, long lordId2) {
		PartyData partyData1 = getPartyByLordId(lordId1);
		PartyData partyData2 = getPartyByLordId(lordId2);
		if (partyData1 != null && partyData2 != null && partyData1.getPartyId() != 0 && partyData1.getPartyId() == partyData2.getPartyId()) {
			return true;
		}
		return false;
	}

	/**
	* @Description: 得到玩家军团信息
	* @param lordId
	* @return  
	* Member
	 */
	public Member getMemberById(long lordId) {
		return memberMap.get(lordId);
	}

	/**
	* @Description: 得到军团列表map
	* @return  
	* Map<Integer,PartyData>
	 */
	public Map<Integer, PartyData> getPartyMap() {
		return partyMap;
	}

	/**
	* @Description: 得到军团成员信息
	* @param partyId
	* @return  
	* List<Member>
	 */
	public List<Member> getMemberList(int partyId) {
		return partyMembers.get(partyId);
	}

	/**
	* @Description: 得到军团数量
	* @param partyId
	* @return  
	* int
	 */
	public int getPartyMemberCount(int partyId) {
		if (partyId == 0) {
			return 0;
		}

		List<Member> members = partyMembers.get(partyId);
		if (members == null) {
			return 0;
		}

		return members.size();
	}

	/**
	* @Description: 得到军团某职位人数
	* @param partyId
	* @param job
	* @return  
	* int
	 */
	public int getMemberJobCount(int partyId, int job) {
		List<Member> members = partyMembers.get(partyId);
		Iterator<Member> it = members.iterator();
		int count = 0;
		while (it.hasNext()) {
			Member next = it.next();
			if (next.getJob() == job) {
				count++;
			}
		}
		return count;
	}

	/**
	* 玩家的军团的科技列表map
	* @param 
	* @return  
	* Map<Integer,PartyScience>KEY:军团科技id
	 */
	public Map<Integer, PartyScience> getScience(Player player) {
		PartyData partyData = getPartyByLordId(player.roleId);
		if (partyData == null) {
			return null;
		}
		return partyData.getSciences();
	}

	/**
	* 军团排行列表
	* @param page
	* @param type
	* @param level
	* @param fight
	* @return  
	* List<PartyRank>
	 */
	public List<PartyRank> getPartyRank(int page, int type, int level, long fight) {
		List<PartyRank> rs = new ArrayList<PartyRank>();
		int size = partyRanks.size();
		int index = page * 20;
		int end = (page + 1) * 20;
		if (type == 1) {// 请求全部
			for (int i = index; i < end && i < size; i++) {
				PartyRank ee = partyRanks.get(i);
				rs.add(ee);
			}
		} else if (type == 2) {
			int count = 0;
			for (int i = 0; i < size; i++) {
				PartyRank ee = partyRanks.get(i);
				int partyId = ee.getPartyId();
				PartyData partyData = partyMap.get(partyId);
				if (partyData.getApplyLv() <= level && ee.getFight() <= fight) {
					if (count >= index) {
						rs.add(ee);
					}
					count++;
				}
				if (end <= count) {
					break;
				}
			}
		}
		return rs;
	}

	public List<PartyRank> getPartyRanks() {
		return partyRanks;
	}

	/**
	* 军团名是否存在
	* @param partyName
	* @return  
	* boolean
	 */
	public boolean isNameExist(String partyName) {
		return partyNameMap.containsKey(partyName.trim());
	}

	/**
	* 是否达到服务器最大军团数
	* @return  
	* boolean
	 */
    public boolean isPartyFullInThisServer() {
        return maxPartyIdInThisServer.get() + 1 >= MAX_PARTY_ID_FLAG;
    }

    /**
    * 产生军团id
    * @return  
    * int
     */
    public int createPartyId() {
        if (isPartyFullInThisServer()) {
            throw new IllegalArgumentException("party is full in this server :" + maxPartyIdInThisServer.get());
        }
        return serverSetting.getServerID() * MAX_PARTY_ID_FLAG + maxPartyIdInThisServer.incrementAndGet();
//        int partyId = 0;
//        for (PartyData party : partyMap.values()) {
//            if (party.getPartyId() > partyId) {
//                partyId = party.getPartyId();
//            }
//        }
//        return partyId + 1;
    }

    /**
    * 重置军团成员产生的数据
    * @param member  
    * void
     */
	public void refreshMember(Member member) {
		int today = TimeHelper.getCurrentDay();
		if (today != member.getRefreshTime()) {
			member.setHallMine(new PartyDonate());
			member.setScienceMine(new PartyDonate());
			member.setWealMine(new Weal());
			member.setRefreshTime(today);
			member.setDayWeal(0);
			member.getCombatIds().clear();
			member.setCombatCount(0);
			member.setActivity(0);
			if (TimeHelper.isMonday()) {// 每周一清理掉周贡献活跃
				member.setWeekDonate(0);
				member.setWeekAllDonate(0);
			}

			// 更新商品
			if (member.getPartyId() != 0) {
				refreshPartyProp(member);
			}
			member.setRefreshTime(today);
		}
	}

	/**
	* 重置军团商店道具
	* @param member  
	* void
	 */
	public void refreshPartyProp(Member member) {
		member.getPartyProps().clear();
		Iterator<StaticPartyProp> it = staticPartyDataMgr.getPropMap().values().iterator();
		while (it.hasNext()) {
			StaticPartyProp next = it.next();
			if (next.getTreasure() == 1) {
				PartyProp partyProp = new PartyProp(next);
				member.getPartyProps().add(partyProp);
			}
		}
	}

	/**
	* 创建军团
	* @param lord 创建人
	* @param member
	* @param partyName
	* @param apply
	* @param day
	* @return  
	* PartyData
	 */
	public PartyData createParty(Lord lord, Member member, String partyName, int apply, int day) {
		int currentDay = TimeHelper.getCurrentDay();
		Party party = new Party();
		party.setPartyId(createPartyId());
		party.setPartyName(partyName);
		party.setApply(apply);
		party.setPartyLv(1);
		party.setScienceLv(1);
		party.setWealLv(1);
		party.setAltarLv(1);
		party.setLegatusName(lord.getNick());
		party.setFight(lord.getFight());
		party.setRefreshTime(day);
		PartyData partyData = new PartyData(party);

		party.setMine(partyData.serMine());
		party.setScience(partyData.serScience());
		party.setTrend(partyData.serTrend());
		party.setAmyProps(partyData.serAmyProps());
		party.setApplyList(partyData.serPartyApply());
		party.setPartyCombat(partyData.serPartyCombat());
		party.setRefreshTime(currentDay);

		partyMap.put(party.getPartyId(), partyData);
		partyNameMap.put(partyName, partyData);

		PartyRank partyRank = new PartyRank(party);
		addPartyRank(partyRank, true);

		enterParty(party.getPartyId(), 1, member);
		member.setJob(PartyType.LEGATUS);

		return partyData;
	}

	/**
	* 军团新成员
	* @param lord
	* @param job
	* @return  
	* Member
	 */
	public Member createNewMember(Lord lord, int job) {
		Member member = new Member();
		member.setLordId(lord.getLordId());
		member.setJob(job);

		memberMap.put(lord.getLordId(), member);
		return member;
	}

	/**
	 * 参与军团活跃任务
	 *
	 * @param member
	 * @param taskId
	 * @param count
	 */
	static public void doPartyLivelyTask(PartyData partyData, Member member, int taskId) {
		LiveTask liveTask = partyData.getLiveTasks().get(taskId);
		if (liveTask == null) {
			liveTask = new LiveTask();
			liveTask.setTaskId(taskId);
			partyData.getLiveTasks().put(taskId, liveTask);
		}

		int count = liveTask.getCount() + 1;
		int activity = 0;

		if (taskId == PartyType.TASK_DONATE) {
			if (count > 500) {
				return;
			}
			activity = 1;
		} else if (taskId == PartyType.TASK_COMBAT) {
			if (count > 100) {
				return;
			}
			activity = 2;
		} else if (taskId == PartyType.TASK_BUY_SHOP) {
			if (count > 30) {
				return;
			}
			activity = 5;
		} else if (taskId == PartyType.TASK_ARMY) {
			if (count > 30) {
				return;
			}
			activity = 5;
		} else if (taskId == PartyType.TASK_TEAM) {
			if (count > 50) {
				return;
			}
			activity = 3;
		}

		member.setActivity(member.getActivity() + activity);
		partyData.setLively(partyData.getLively() + activity);
		liveTask.setCount(count);
	}

	/**
	 * 得到玩家军团名
	 * @param lordId
	 * @return
	 */
	public String getPartyNameByLordId(long lordId) {
		Member member = memberMap.get(lordId);
		if (member == null || member.getPartyId() == 0) {
			return null;
		}
		int partyId = member.getPartyId();
		PartyData partyData = partyMap.get(partyId);
		if (partyData == null) {
			return null;
		}
		return partyData.getPartyName();
	}

	/**
	* 加入军团
	* @param partyId
	* @param lv
	* @param member
	* @return  
	* int
	 */
	public int enterParty(int partyId, int lv, Member member) {
		List<Member> list = partyMembers.get(partyId);

		if (list == null) {
			list = new ArrayList<>();
			partyMembers.put(partyId, list);
		}

		int count = staticPartyDataMgr.getLvNum(lv);
		if (list.size() >= count) {
			return 2;
		}

		member.enterParty(partyId);
		list.add(member);

		if (member.getPartyProps().isEmpty()) {
			refreshPartyProp(member);
		}

		return 0;
	}

	/**
	* 玩家退出军团
	* @param partyId
	* @param member  
	* void
	 */
	public void quitParty(int partyId, Member member) {
		member.quitParty();
		List<Member> list = partyMembers.get(partyId);
		if (list != null) {
			Iterator<Member> it = list.iterator();
			while (it.hasNext()) {
				Member e = (Member) it.next();
				if (e.getLordId() == member.getLordId()) {
					it.remove();
				}
			}
		}
	}

	/**
	* 军团排行中增加军团
	* @param partyRank
	* @param flag  
	* void
	 */
	public void addPartyRank(PartyRank partyRank, boolean flag) {
		if (flag) {
			int rank = partyRanks.size();
			partyRank.setRank(rank + 1);
		}
		partyRanks.add(partyRank);
		// rankMap.put(partyRank.getPartyId(), partyRank);
	}

	/**
	* 减少军团贡献
	* @param member
	* @param sub
	* @return  
	* boolean
	 */
	public boolean subDonate(Member member, int sub) {
		int donate = member.getDonate();
		if (donate < sub) {
			return false;
		}
		member.setDonate(donate - sub);
		return true;
	}

	/**
	 * Depicts:帮派成员采集世界资源,进行累计记录
	 *
	 * @param lordId
	 * @param grab
	 */
	public void collectMine(long lordId, Grab grab) {
		Member member = memberMap.get(lordId);
		if (member != null && member.getPartyId() != 0) {
			int partyId = member.getPartyId();
			PartyData partyData = partyMap.get(partyId);
			refreshPartyData(partyData);
			Weal reportMine = partyData.getReportMine();
			reportMine.setIron(reportMine.getIron() + grab.rs[0]);
			reportMine.setOil(reportMine.getOil() + grab.rs[1]);
			reportMine.setCopper(reportMine.getCopper() + grab.rs[2]);
			reportMine.setSilicon(reportMine.getSilicon() + grab.rs[3]);
			reportMine.setStone(reportMine.getStone() + grab.rs[4]);
		}
	}

	/**
	 * Function:军团军情、民情添加
	 *
	 * @param partyId
	 * @param trendId
	 * @param param
	 */
	public boolean addPartyTrend(int partyId, int trendId, String... param) {
		PartyData partyData = partyMap.get(partyId);
		if (partyData != null) {
			StaticPartyTrend staticTrend = staticPartyDataMgr.getPartyTrend(trendId);
			if (staticTrend == null) {
				return false;
			}
			Trend trend = new Trend(trendId, TimeHelper.getCurrentSecond());
			trend.setTrendId(trendId);
			trend.setParam(param);
			partyData.getTrends().add(trend);

			// 数量超过50
			if (partyData.getTrends().size() > 50) {
				int type = staticTrend.getType();
				Trend temp = null;
				int count = 0;
				Iterator<Trend> it = partyData.getTrends().iterator();
				while (it.hasNext()) {
					Trend next = it.next();
					if (next == null) {
						continue;
					}
					int nextId = next.getTrendId();
					StaticPartyTrend strend = staticPartyDataMgr.getPartyTrend(nextId);
					if (strend == null) {
						continue;
					}
					if (type == strend.getType()) {
						if (temp == null) {
							temp = next;
						}
						count++;
					}
				}
				if (count > 50) {
					partyData.getTrends().remove(temp);
				}
			}
			return true;
		}
		return false;
	}

	/**
	* 
	* @param trendId
	* @param targe
	* @param gay
	* @param param
	* @return  
	* boolean
	 */
	public boolean addPartyTrend(int trendId, Player targe, Player gay, String param) {
		long targeId = targe.roleId;
		PartyData partyData = getPartyByLordId(targeId);
		if (partyData != null) {
			int partyId = partyData.getPartyId();
			long gayId = gay.roleId;
			String lordId1 = String.valueOf(targeId);
			String lordId2 = String.valueOf(gayId);
			String partyName = " ";
			PartyData partyData2 = getPartyByLordId(gayId);
			if (partyData2 != null) {
				partyName = partyData2.getPartyName();
			}
			if (partyName == null) {
				partyName = " ";
			}
			if (param != null) {
				addPartyTrend(partyId, trendId, lordId1, partyName, lordId2, param);
			} else {
				addPartyTrend(partyId, trendId, lordId1, partyName, lordId2);
			}
			return true;
		}
		return false;
	}

	/**
	 * 军团战:战事福利
	 *
	 * @param partyId
	 * @param props
	 */
	public void addAmyProps(int partyId, List<Prop> props) {
		PartyData partyData = getParty(partyId);
		if (partyData == null || props == null) {
			return;
		}
		Map<Integer, Prop> amyProps = partyData.getAmyProps();
		for (Prop e : props) {
			Prop prop = amyProps.get(e.getPropId());
			if (prop == null) {
				prop = new Prop(e.getPropId(), e.getCount());
				amyProps.put(e.getPropId(), prop);
			} else {
				prop.setCount(prop.getCount() + e.getCount());
			}
		}
	}

	/**
	* 重置军团数据
	* @param partyData  
	* void
	 */
	public void refreshPartyData(PartyData partyData) {
		int today = TimeHelper.getCurrentDay();
		int refreshDate = partyData.getRefreshTime();
		if (refreshDate != today) {
			int pass = TimeHelper.subDay(today, refreshDate);
			for (int i = 0; i < pass; i++) {
				int lively = partyData.getLively();
				lively = staticPartyDataMgr.costLively(lively);
				partyData.setLively(lively);
			}

			partyData.getPartyCombats().clear();
			partyData.getLiveTasks().clear();
			partyData.setRefreshTime(today);
			if (partyData.getDonates(1) != null) {
				partyData.getDonates(1).clear();
			}
			if (partyData.getDonates(2) != null) {
				partyData.getDonates(2).clear();
			}
			Weal reportMine = partyData.getReportMine();
			if (reportMine != null) {
				reportMine.setCopper(0);
				reportMine.setGold(0);
				reportMine.setIron(0);
				reportMine.setOil(0);
				reportMine.setSilicon(0);
				reportMine.setStone(0);
			}
//			List<Integer> shopProps = partyData.getShopProps();
//			for (int i = 0; i < shopProps.size(); i++) {
//				shopProps.set(i, 0);
//			}
		}
	}

	/**
	* 
	* @param name
	* @return  
	* PartyRank
	 */
	public PartyRank getPartyRankByName(String name) {
		PartyData partyData = partyNameMap.get(name);
		if (partyData != null) {
			return getPartyRank(partyData.getPartyId());
		}

		return null;
	}


	public PartyRank getPartyRank(int partyId) {
		Iterator<PartyRank> it = partyRanks.iterator();
		while (it.hasNext()) {
			PartyRank partyRank = it.next();
			int tempId = partyRank.getPartyId();
			if (partyId == tempId) {
				return partyRank;
			}
		}
		return null;
	}

	/**
	* 保存进数据库
	* @param party  
	* void
	 */
	public void updatePartyData(Party party) {
		if (partyDao.updatePary(party) == 0) {
			partyDao.insertPary(party);
		}
	}

	/**
	* 获得军团的排名数
	* @param partyId
	* @return  
	* int
	 */
	public int getRank(int partyId) {
		PartyRank partyRank = getPartyRank(partyId);
		if (partyRank != null) {
			return partyRank.getRank();
		}

		return -1;
	}

	/**
	* 取得军团捐献中的某资源数
	* @param partyDonate
	* @param resourceId
	* @return  
	* int
	 */
	public int getDonateMember(PartyDonate partyDonate, int resourceId) {
		if (resourceId == PartyType.RESOURCE_STONE) {
			return partyDonate.getStone();
		} else if (resourceId == PartyType.RESOURCE_IRON) {
			return partyDonate.getIron();
		} else if (resourceId == PartyType.RESOURCE_SILICON) {
			return partyDonate.getSilicon();
		} else if (resourceId == PartyType.RESOURCE_COPPER) {
			return partyDonate.getCopper();
		} else if (resourceId == PartyType.RESOURCE_OIL) {
			return partyDonate.getOil();
		} else if (resourceId == PartyType.RESOURCE_GOLD) {
			return partyDonate.getGold();
		}
		return 999;
	}

	/**
	* 军团成员是否在战斗中
	* @param member
	* @return  
	* boolean
	 */
	public boolean inWar(Member member) {
		if (TimeHelper.isWarDay()) {
			int state = globalDataManager.gameGlobal.getWarState();
			if ((state >= WarState.REG_STATE && state <= WarState.FIGHT_END) && member.getRegLv() != 0) {
				return true;
			}
		}
		return false;
	}

	/**   军团改名
	* Method: rename
	* @Description:
	* @param partyData
	* @param partyName
	* @return void

	*/
	public void rename(PartyData partyData, String partyName) {
		// 移除老的名字
		partyNameMap.remove(partyData.getPartyName());
		partyData.setPartyName(partyName);
		partyNameMap.put(partyName, partyData);
	}

		/**
	 * 军团名是否已存在
	* Method: isExistPartyName
	* @Description:
	* @param partyName
	* @return
	* @return boolean

	 */
	public boolean isExistPartyName(String partyName) {
		return (partyName != null && partyNameMap.containsKey(partyName.trim()));
	}

	/** 获取成员根据官职升序 军团战--- */
	public List<Member> getMemberListOrderByJob(int partyId) {
		List<Member> members = partyMembers.get(partyId);
		if(members == null){
			return new ArrayList<>();
		}
		Collections.sort(members, new Comparator<Member>() {

			@Override
			public int compare(Member o1, Member o2) {
//				PartyType
//				public static final int LEGATUS = 99;// 军团长
//				public static final int LEGATUS_CP = 90;// 副军团长
//				public static final int COMMON = 10;// 普通成员
//				public static final int JOB1 = 20;// 设置职位1
//				public static final int JOB2 = 25;// 设置职位2
//				public static final int JOB3 = 30;// 设置职位3
//				public static final int JOB4 = 35;// 设置职位4
				return o2.getJob() - o1.getJob();
			}

		});
		return members;
	}
	
	//军团充值结束后在每个成员身上记录一下军团Id
	public void signPartyRecharge() {
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAY_PARTY);
        if (activityBase == null) {//活动结束后重置数据
        		for(PartyData partyData:partyMap.values()) {
					if (partyData.getTeamRecharge() > 0) {
						LogUtil.error("军团Id:"+partyData.getPartyId()+"|军团充值金额："+partyData.getTeamRecharge());
						partyData.setTeamRecharge(0);
    					partyData.copyData();
    				}

        		}
        		
        		Map<Long, Player> playerMap = playerDataManager.getPlayers();
        		for(Player player:playerMap.values()) {
        			if(player != null ) {
        				if(player.lord.getOldPartyId()>0) {
        					player.lord.setOldPartyId(0);
        				}
        			}
        		}
        	
            return;
        }
        
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_AWARD) {
            return;
        }
        List<StaticActAward> awardList = staticActivityDataMgr.getActAwardById(activityBase.getPlan().getAwardId());
        for(Member member:memberMap.values()) {
			try {
				if(member.getPartyId()>0) {
                    Player player = playerDataManager.getPlayer(member.getLordId());
                    if( player != null ){
                        if(player.lord.getOldPartyId()==0) {
                            Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_PARTY);
                            Map<Integer, Integer> statusMap = activity.getStatusMap();
                            PartyData partyData = this.getParty(member.getPartyId());
                            for (StaticActAward actAward : awardList) {
                                int keyId = actAward.getKeyId();
                                Integer status = statusMap.get(keyId);
                                if (status == null || status == 2) { // 如果未领奖则查看是否满足领奖条件，如果满足则设置为可领奖状态
                                    if (partyData.getTeamRecharge() >= actAward.getCond()) {
                                        statusMap.put(keyId, 0);
                                    }else {
                                        statusMap.put(keyId, 2);
                                    }
                                }
                            }
                            player.lord.setOldPartyId(member.getPartyId());
                        }
                    }
                }
			} catch (Exception e) {
				LogUtil.error(e);
			}
		}
		LogUtil.info("军团充值活动,统计完毕");
	}
}
