/**   
 * @Title: ArenaDataManager.java    
 * @Package com.game.manager    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 上午11:31:58    
 * @version V1.0   
 */
package com.game.manager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import com.game.service.ArenaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.p.ArenaDao;
import com.game.dao.impl.p.ServerLogDao;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.p.Arena;
import com.game.domain.p.ArenaLog;
import com.game.domain.s.StaticArenaAward;
import com.game.util.RandomHelper;
import com.game.util.TimeHelper;
import com.google.protobuf.InvalidProtocolBufferException;

/**
 * @ClassName: ArenaDataManager
 * @Description: 竞技场
 * @author ZhangJun
 * @date 2015年9月7日 上午11:31:58
 */
@Component
public class ArenaDataManager {
	@Autowired
	private ArenaDao arenaDao;

	@Autowired
	private StaticDataDao staticDataDao;

	// @Autowired
	// private StaticMailDataMgr staticMailDataMgr;

	@Autowired
	private ServerLogDao serverLogDao;

	private Map<Integer, Arena> rankMap;

	// 每天0点更新的时候刷新,获取上期排名200名
	private Map<Integer, Arena> lastRankMap = new HashMap<Integer, Arena>();

	private Map<Long, Arena> playerMap;

	private List<StaticArenaAward> rankAward;

	private ArenaLog arenaLog;

	@Autowired
	private SmallIdManager smallIdManager;

	@Autowired
	private ArenaService arenaService;

//	@PostConstruct
	public void init() throws InvalidProtocolBufferException {
		initArenaData();
		initArenaLog();
		initRankAward();

		//启服的时候,执行一下,判断如果当天未执行则执行一次
		arenaService.arenaTimerLogic();
		// initGlobal();
	}

	public Map<Integer, Arena> getLastRankMap() {
		return lastRankMap;
	}

	public void setLastRankMap(Map<Integer, Arena> lastRankMap) {
		this.lastRankMap = lastRankMap;
	}

	private void initArenaData() {
		fillData();
		playerMap = new HashMap<Long, Arena>();
		Iterator<Arena> it = rankMap.values().iterator();
		while (it.hasNext()) {
			Arena arena = (Arena) it.next();
			if (!smallIdManager.isSmallId(arena.getLordId())) {
				playerMap.put(arena.getLordId(), arena);
			}
		}
	}

	private void fillData() {
		rankMap = new TreeMap<>();
		List<Arena> list = arenaDao.load();

		Arena arena;
		int rank = 1;
		for (int i = 0; i < list.size(); i++) {
			arena = list.get(i);
			if (!smallIdManager.isSmallId(arena.getLordId())) {
				arena.setRank(rank);
				rankMap.put(arena.getRank(), arena);

				// 填充上期排名
				if (arena.getLastRank() >= 1 && arena.getLastRank() <= 200) {
					lastRankMap.put(arena.getLastRank(), arena);
				}

				rank++;
			}
		}
	}

	private void initArenaLog() {
		arenaLog = serverLogDao.selectLastArenaLog();
		if (arenaLog == null) {
			arenaLog = new ArenaLog(TimeHelper.getCurrentDay(), 0);
		}
	}

	private void initRankAward() {
		rankAward = staticDataDao.selectArenaAward();
	}

	public ArenaLog getArenaLog() {
		return arenaLog;
	}

	public void setArenaLog(ArenaLog arenaLog) {
		this.arenaLog = arenaLog;
	}

	public void flushArenaLog() {
		serverLogDao.insertArenaLog(arenaLog);
	}

	public Map<Integer, Arena> getRankMap() {
		return rankMap;
	}

	public void setRankMap(Map<Integer, Arena> rankMap) {
		this.rankMap = rankMap;
	}

	public Arena getArena(long lordId) {
		return playerMap.get(lordId);
	}

	public Arena getArenaByRank(int rank) {
		return rankMap.get(rank);
	}

	public Arena getArenaByLastRank(int rank) {
		return lastRankMap.get(rank);
	}

	public List<Arena> randomEnemy(int rank) {
		List<Arena> list = new ArrayList<>();
		int arenaSize = rankMap.size();
		if (rank > 15000) {
			list.add(rankMap.get(rank - 200));
			list.add(rankMap.get(rank - 400));
			list.add(rankMap.get(rank - 600));
			list.add(rankMap.get(rank - 800));
		} else if (rank > 5000) {
			list.add(rankMap.get(rank - 100));
			list.add(rankMap.get(rank - 200));
			list.add(rankMap.get(rank - 300));
			list.add(rankMap.get(rank - 400));
		} else if (rank > 1000) {
			list.add(rankMap.get(rank - 50));
			list.add(rankMap.get(rank - 100));
			list.add(rankMap.get(rank - 150));
			list.add(rankMap.get(rank - 200));
		} else if (rank > 500) {
			list.add(rankMap.get(rank - 20));
			list.add(rankMap.get(rank - 40));
			list.add(rankMap.get(rank - 60));
			list.add(rankMap.get(rank - 80));
		} else if (rank > 200) {
			list.add(rankMap.get(rank - 15));
			list.add(rankMap.get(rank - 30));
			list.add(rankMap.get(rank - 45));
			list.add(rankMap.get(rank - 60));
		} else if (rank > 100) {
			list.add(rankMap.get(rank - 10));
			list.add(rankMap.get(rank - 20));
			list.add(rankMap.get(rank - 30));
			list.add(rankMap.get(rank - 40));
		} else if (rank > 50) {
			list.add(rankMap.get(rank - 40 + RandomHelper.randomInSize(10)));
			list.add(rankMap.get(rank - 30 + RandomHelper.randomInSize(10)));
			list.add(rankMap.get(rank - 20 + RandomHelper.randomInSize(10)));
			list.add(rankMap.get(rank - 10 + RandomHelper.randomInSize(10)));
		} else if (rank > 20) {
			list.add(rankMap.get(rank - 16 + RandomHelper.randomInSize(4)));
			list.add(rankMap.get(rank - 12 + RandomHelper.randomInSize(4)));
			list.add(rankMap.get(rank - 8 + RandomHelper.randomInSize(4)));
			list.add(rankMap.get(rank - 4 + RandomHelper.randomInSize(4)));
		} else if (rank > 10) {
			list.add(rankMap.get(rank - 8 + RandomHelper.randomInSize(2)));
			list.add(rankMap.get(rank - 6 + RandomHelper.randomInSize(2)));
			list.add(rankMap.get(rank - 4 + RandomHelper.randomInSize(2)));
			list.add(rankMap.get(rank - 2 + RandomHelper.randomInSize(2)));
		} else if (rank > 8) {
			list.add(rankMap.get(rank - 7));
			list.add(rankMap.get(rank - 4));
			list.add(rankMap.get(rank - 2));
			list.add(rankMap.get(rank - 1));
		} else if (rank > 6) {
			list.add(rankMap.get(rank - 6));
			list.add(rankMap.get(rank - 3));
			list.add(rankMap.get(rank - 2));
			list.add(rankMap.get(rank - 1));
		} else if (rank == 6) {
			list.add(rankMap.get(1));
			list.add(rankMap.get(3));
			list.add(rankMap.get(4));
			list.add(rankMap.get(5));
		} else if (rank == 5) {
			list.add(rankMap.get(1));
			list.add(rankMap.get(2));
			list.add(rankMap.get(3));
			list.add(rankMap.get(4));
		} else if (rank == 4) {
			list.add(rankMap.get(1));
			list.add(rankMap.get(2));
			list.add(rankMap.get(3));
			if (arenaSize > 5) {
				list.add(rankMap.get(6));
			}
		} else if (rank == 3) {
			list.add(rankMap.get(1));
			list.add(rankMap.get(2));
			if (arenaSize > 4) {
				list.add(rankMap.get(5));
			}

			if (arenaSize > 5) {
				list.add(rankMap.get(6));
			}
		} else if (rank == 2) {
			list.add(rankMap.get(1));
			if (arenaSize > 3) {
				list.add(rankMap.get(4));
			}

			if (arenaSize > 4) {
				list.add(rankMap.get(5));
			}

			if (arenaSize > 5) {
				list.add(rankMap.get(6));
			}
		} else if (rank == 1) {
			if (arenaSize > 2) {
				list.add(rankMap.get(3));
			}

			if (arenaSize > 3) {
				list.add(rankMap.get(4));
			}

			if (arenaSize > 4) {
				list.add(rankMap.get(5));
			}

			if (arenaSize > 5) {
				list.add(rankMap.get(6));
			}
		}

		if (rank != rankMap.size()) {
			list.add(rankMap.get(rank + 1));
		}
		return list;
	}

	public Arena addNew(long lordId) {
		Arena arena = new Arena();
		arena.setLordId(lordId);
		arena.setCount(5);
		arena.setRank(playerMap.size() + 1);
		arena.setArenaTime(TimeHelper.getCurrentDay());
		playerMap.put(lordId, arena);
		rankMap.put(arena.getRank(), arena);
		return arena;
	}

	private void refreshArena(Arena arena) {
		int nowDay = TimeHelper.getCurrentDay();
		if (arena.getArenaTime() != nowDay) {
			arena.setCount(5);
			arena.setBuyCount(0);
			arena.setArenaTime(nowDay);
		}
	}

	public Arena enterArena(long lordId) {
		Arena arena = playerMap.get(lordId);
		if (arena != null) {
			refreshArena(arena);
		}
		return arena;
	}

	/**
	 * 
	 * Method: exchangeArena
	 * 
	 * @Description: 交换排名 @param arena1 @param arena2 @return void @throws
	 */
	public void exchangeArena(Arena arena1, Arena arena2) {
		int rank = arena1.getRank();
		arena1.setRank(arena2.getRank());
		arena2.setRank(rank);
		rankMap.put(arena1.getRank(), arena1);
		rankMap.put(arena2.getRank(), arena2);
	}

	public StaticArenaAward getRankAward(int rank) {
		for (int i = 0; i < rankAward.size(); i++) {
			StaticArenaAward staticArenaAward = rankAward.get(i);
			if (rank >= staticArenaAward.getBeginRank() && rank <= staticArenaAward.getEndRank()) {
				return staticArenaAward;
			}
		}
		return null;
	}

}
