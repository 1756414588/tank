package merge;

import com.game.constant.ActivityConst;
import com.game.constant.SystemId;
import com.game.dao.impl.p.StaticParamDao;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.StaticParam;
import com.game.domain.s.*;
import com.game.manager.WorldDataManager;
import com.game.util.*;

import java.util.*;


public class MergeGameManager {
	private int appId = 0;

	private int newServerId;

	private int maxPartyId;
	private long maxLordId;
	
	private int act43begin;
	
	private int buffFreeTime;
	
	private int smallLordLv;
	
	public final Set<String> usedNick = new HashSet<>();
	public Map<Integer, Map<Long, String>> usedNickLord = new HashMap<>();
	
	public final Set<String> usedPartyNick = new HashSet<>();
	public Map<Integer, Map<Integer, String>> usedPartyNickLord = new HashMap<>();

	public MergeGameManager(int appId, int newServerId,MServer iniDb,MyBatisM myBatisMain,int smallLordLv) {
		this.appId = appId;
		this.newServerId = newServerId;
		this.smallLordLv = smallLordLv;
		
		MyBatisM myBatisInit = null;
		try {
			myBatisInit = new MyBatisM(iniDb.getDbUrl(), iniDb.getUser(), iniDb.getPwd());
		} catch (Exception e) {
			LogUtil.error(e);
			System.exit(-1);
		}
		StaticDataDao staticDataDao = new StaticDataDao();
		staticDataDao.setSqlSessionFactory(myBatisInit.getSqlSessionFactory());
		
		Map<Integer, StaticAirship> airshipMap = staticDataDao.selectStaticAirshipMap();
		this.airshipMap = airshipMap;
		
		Map<Integer, StaticMine> mineMap = staticDataDao.selectMine();
		this.mineMap = mineMap;
		
		List<StaticSlot> slots = staticDataDao.selectSlot();
		this.slots = slots;
		
		Map<Integer, StaticSystem> staticSystemMap = staticDataDao.selectSystemMap();
		buffFreeTime = Integer.valueOf(staticSystemMap.get(SystemId.MERGE_GAME_BUFF_FREE_TIME).getValue());
		
		caluFreePostList();
		//查询活动时间 暂时只处理43活动
		initAct(myBatisMain,myBatisInit);
	}

	public int getPartyId() {
		if (this.maxPartyId == 0) {
//			this.maxPartyId = (this.appId * 100000);
		}
		return ++this.maxPartyId;
	}

	public long getLordId() {
		if (this.maxLordId == 0L) {
			this.maxLordId = (this.appId * 100000);
		}
		return ++this.maxLordId;
	}

	public int getAppId() {
		return this.appId;
	}

	public int getNewServerId() {
		return this.newServerId;
	}
	
	public int getAct43begin() {
		return act43begin;
	}

	public int getBuffFreeTime() {
		return buffFreeTime;
	}
	
	public int getSmallLordLv() {
		return smallLordLv;
	}

	static final int INVALID_POS_1 = 298 + 298 * 600;
	static final int INVALID_POS_2 = 299 + 298 * 600;
	static final int INVALID_POS_3 = 300 + 298 * 600;

	static final int INVALID_POS_4 = 298 + 299 * 600;
	static final int INVALID_POS_5 = 299 + 299 * 600;
	static final int INVALID_POS_6 = 300 + 299 * 600;

	static final int INVALID_POS_7 = 298 + 300 * 600;
	static final int INVALID_POS_8 = 299 + 300 * 600;
	static final int INVALID_POS_9 = 300 + 300 * 600;

	public boolean isValidPos(int pos) {
		if (pos == INVALID_POS_1 || pos == INVALID_POS_2 || pos == INVALID_POS_3 || pos == INVALID_POS_4 || pos == INVALID_POS_5 || pos == INVALID_POS_6
				|| pos == INVALID_POS_7 || pos == INVALID_POS_8 || pos == INVALID_POS_9) {
			return false;
		}
		if(pos >= 360000 || pos < 1){
			return false;
		}
		return true;
	}
	
	// 世界地图上的玩家
	private Map<Integer, Long> posMap = new HashMap<Integer, Long>();
	// 空余的位置信息
	private List<Integer> freePostList = new ArrayList<Integer>();
	
	public  void addNewPlayer(Player player) {
		synchronized (freePostList) {
			int pos;
			int slot;
			int xBegin;
			int yBegin;
			
			int times = 0;
			while (true) {
				slot = getSlot(posMap.size());
				xBegin = slot % 20 * 30;
				yBegin = slot / 20 * 30;
				pos = (RandomHelper.randomInSize(30) + xBegin) + (RandomHelper.randomInSize(30) + yBegin) * 600;
				if (posMap.containsKey(pos) || evaluatePos(pos) != null || !isValidPos(pos) || isRebel(pos)) {
					times++;

					if (times >= 100) {
						pos = freePostList.get(0);

						if (freePostList.size() < 10000) {
//							LogHelper.ERROR_LOGGER.error("位置不够了,请注意, 剩余:" + freePostList.size() + ", 已分配:" + posMap.size());
							LogUtil.warn("空闲位置不够了,请注意, 剩余:" + freePostList.size() + ", 已分配:" + posMap.size());
						}
						break;
					}
					continue;
				}
				break;
			}

			player.lord.setPos(pos);
			putPlayer(player);
		}
	}
	
	public void putPlayer(Player player) {
		int pos = player.lord.getPos();
		if (pos != -1) {
			posMap.put(pos, player.lord.getLordId());
			freePostList.remove(Integer.valueOf(pos));
		}
	}
	
	public int area(int pos) {
		Tuple<Integer, Integer> xy = reducePos(pos);
		return xy.getA() / 15 + xy.getB() / 15 * 40;
	}
	
	static public Tuple<Integer, Integer> reducePos(int pos) {
		Tuple<Integer, Integer> turple = new Tuple<Integer, Integer>(pos % 600, pos / 600);
		return turple;
	}
	
	public StaticMine evaluatePos(int pos) {
		Tuple<Integer, Integer> xy = reducePos(pos);
		int x = xy.getA();
		int y = xy.getB();
		int index = x / 40 + y / 40 * 15;
		int reflection = (x % 40 + y % 40 * 40 + 13 * index) % 1600;
		StaticMine staticMine = getMine(reflection);
		return staticMine;
	}
	public boolean isRebel(int pos) {//合服时全局数据清空
		return false;
	}
	
	private List<StaticSlot> slots;
	private Map<Integer, StaticMine> mineMap;
	private Map<Integer, StaticAirship> airshipMap;
	
	public StaticMine getMine(int pos) {
		return mineMap.get(pos);
	}
	
	public int getSlot(int playerNumber) {
		int index = playerNumber / 400;
		if (index > 199) {
			return RandomHelper.randomInSize(400);
		} else {
			// return 125;
			StaticSlot staticSlot = slots.get(index);
			if (playerNumber % 2 == 0) {
				return staticSlot.getSlotA();
			} else {
				return staticSlot.getSlotB();
			}
		}
	}
	
	/**
	 * 计算空余位置list后并混乱
	 */
	public void caluFreePostList() {
		for (int pos = 1; pos < 360000; pos++) {
			if (posMap.containsKey(pos) || evaluatePos(pos) != null || !isValidPos(pos) || isRebel(pos)) {
				continue;
			} else {
				freePostList.add(pos);
			}
		}

		Collections.shuffle(freePostList);
		
		//飞艇的删除
		for (StaticAirship  sap: airshipMap.values()) {
			Tuple<Integer, Integer> t = MapHelper.reducePos(sap.getPos());
			int[] xy =  new int[]{t.getA(),t.getB()};
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
				Integer pos = WorldDataManager.pos(x,y);
				freePostList.remove(pos);
			}
		}
	}
	
	private void initAct(MyBatisM myBatisMain,MyBatisM myBatisInit) {
		StaticParamDao staticParamDao = new StaticParamDao();
		StaticDataDao staticDataDao = new StaticDataDao();
		staticParamDao.setSqlSessionFactory(myBatisMain.getSqlSessionFactory());
		staticDataDao.setSqlSessionFactory(myBatisInit.getSqlSessionFactory());
		
		String openTimeStr = null;
		int activityMoldId = -1;
		List<StaticParam> params = staticParamDao.selectStaticParams();
		for (int i = 0; i < params.size(); i++) {
			StaticParam param = (StaticParam) params.get(i);
			if (param.getParamName().equals("openTime")) {
				openTimeStr = param.getParamValue();
			}else if (param.getParamName().equals("actMold")) {
				activityMoldId = Integer.valueOf(param.getParamValue());
			}
		}
		
		Map<Integer, StaticActivity> activityMap = staticDataDao.selectStaticActivity();
		List<StaticActivityPlan> planList = staticDataDao.selectStaticActivityPlan();
		Date openTime = DateHelper.parseDate(openTimeStr);
		List<ActivityBase> activityList = new ArrayList<ActivityBase>();
		for (StaticActivityPlan e : planList) {
			int activityId = e.getActivityId();
			StaticActivity staticActivity = activityMap.get(activityId);
			if (staticActivity == null) {
				continue;
			}
			int moldId = e.getMoldId();
			if (activityMoldId != moldId) {
				continue;
			}
			ActivityBase activityBase = new ActivityBase();
			activityBase.setOpenTime(openTime);
			activityBase.setPlan(e);
			activityBase.setStaticActivity(staticActivity);
			boolean flag = activityBase.initData();
			if (flag) {
				activityList.add(activityBase);
			}
		}
		
		for (ActivityBase base : activityList) {
			if(ActivityConst.ACT_VIP_GIFT == base.getActivityId()){
				act43begin = TimeHelper.getDay(base.getBeginTime());
				break;
			}
		}
	}
}
