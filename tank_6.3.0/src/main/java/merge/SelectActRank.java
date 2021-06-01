package merge;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.game.constant.ActivityConst;
import com.game.dao.impl.p.*;
import com.game.domain.p.*;
import com.game.pb.CommonPb;
import com.game.pb.SerializePb.SerActPartyRank;
import com.game.pb.SerializePb.SerActPlayerRank;
import com.game.pb.SerializePb.SerData;
import com.game.server.util.FileUtil;
import com.game.util.LogUtil;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

public class SelectActRank {
	
	public static void main(String[] args) {
		//查询线上被合并数据中活动排名领奖记录数据
		try {
//			select48ActRank();
//			select48ActRankNotMerge();
//			select126ActRankNotMerge();
//			selectActRankNotMerge(108);
			getDbUrls();
		} catch (Exception e) {
			e.printStackTrace();
			LogUtil.error(e,e.getCause());
		}
	}
	
	private static void getDbUrls(){
		try {
			JSONArray serverGroup = new JSONArray();
			searchDbUrls(new File("E:/合服/20170110"),serverGroup);
			LogUtil.info("serverGroup:"+serverGroup);
		} catch (Exception e) {
			e.printStackTrace();
			LogUtil.error(e,e.getCause());
		}
	}
	
	private static void searchDbUrls(File file,JSONArray serverGroup){
		if(file.isDirectory()){
			for (File f : file.listFiles()) {
				searchDbUrls(f,serverGroup);
			}
		}else{
			if("mergeServerList.json".equals(file.getName())){
//				LogUtil.info(file.getAbsolutePath());
				JSONObject json = JSONObject.parseObject(FileUtil.readFile(file.getAbsolutePath()));
				serverGroup.add(json.getJSONArray("list"));
			}
		}
	}
	
	public static JSONArray readServerList() {
		String path = "mServers.json";
		Resource resource = new FileSystemResource(path);
		String content = new String();
		if (resource.isReadable()) {
			try {
				String encoding = "UTF-8";
				InputStream is = resource.getInputStream();
				InputStreamReader read = new InputStreamReader(is, encoding);// 考虑到汉子编码格式
				BufferedReader bufferedReader = new BufferedReader(read);
				String lineTxt = null;
				while ((lineTxt = bufferedReader.readLine()) != null) {
					content += lineTxt;
				}

				if (is != null) {
					is.close();
				}
				if (bufferedReader != null) {
					bufferedReader.close();
				}

			} catch (Exception e) {
				LogUtil.error("读取文件内容出错:" + path, e);
				e.printStackTrace();
			}

		} else {
			path = "mServers.json";
			try {
				String encoding = "UTF-8";
				InputStream inputStream = MServerListReader.class.getClassLoader().getResourceAsStream(path);

				InputStreamReader read = new InputStreamReader(inputStream, encoding);// 考虑到汉子编码格式
				BufferedReader bufferedReader = new BufferedReader(read);
				String lineTxt = null;
				while ((lineTxt = bufferedReader.readLine()) != null) {
					content += lineTxt;
				}

				if (inputStream != null) {
					inputStream.close();
				}
				if (bufferedReader != null) {
					bufferedReader.close();
				}
			} catch (Exception e) {
				LogUtil.error("读取资源文件内容出错:" + path, e);
				e.printStackTrace();
			}
		}
		return JSONArray.parseArray(content);
	}
	
	private static class PlayerRank{
		long lordId;
		long score;
		boolean isRecv;
		String name;
		
		public PlayerRank(long lordId, long score) {
			this.lordId = lordId;
			this.score = score;
		}
	}

	@SuppressWarnings("unused")
	private static void select104ActRank() throws Exception {
		Class.forName("com.mysql.jdbc.Driver");
		
		JSONArray serverGroup = readServerList();
		for (int i = 0; i < serverGroup.size(); i++) {
			Map<Integer, List<PlayerRank>> serverPlayerMap = new HashMap<Integer, List<PlayerRank>>();
			List<Integer> mergeServerIdList = new ArrayList<>();
			
			List<MServer> oldServers = JSONArray.parseArray(serverGroup.getJSONArray(i).toString(),MServer.class);
			for (MServer mServer : oldServers) {
				//从旧数据库查询，玩家排行榜数据和领取记录
				MyBatisM myBatisM = new MyBatisM(mServer.getDbUrl(), mServer.getUser(), mServer.getPwd());
				
				ActivityDao activityDao = new ActivityDao();
				activityDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				DataNewDao dataNewDao = new DataNewDao();
				dataNewDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				
				//104活动
				int actId = ActivityConst.ACT_PAWN_ID;
				UsualActivity act = null;			
				for (UsualActivity usualActivity : activityDao.selectUsualActivity()) {
					if(usualActivity.getActivityId() == actId){
						act = usualActivity;
						break;
					}
				}
				
				if(act == null){
					continue;
				}
				
				SerActPlayerRank ser = SerActPlayerRank.parseFrom(act.getPlayerRank());
				List<CommonPb.ActPlayerRank> list = ser.getActPlayerRankList();
				for (CommonPb.ActPlayerRank e : list) {
					long lordId = e.getLordId();
					long score = e.getRankValue();
					
					PlayerRank playerRank = new PlayerRank(lordId,score);
					
					List<PlayerRank> playerRankList = serverPlayerMap.get(mServer.getServerId());
					if(playerRankList == null){
						playerRankList = new ArrayList<>();
						serverPlayerMap.put(mServer.getServerId(), playerRankList);
					}
					playerRankList.add(playerRank);
					
					//找到角色看是否领奖
					DataNew dataNew = dataNewDao.selectData(lordId);
					SerData serData = SerData.parseFrom(dataNew.getRoleData());
					List<CommonPb.DbActivity> activityList = serData.getActivityList();
					for (CommonPb.DbActivity ee : activityList) {
						if(ee.getActivityId() == actId){
							for (CommonPb.TwoInt towInt : ee.getTowIntList()) {
								if(towInt.getV1() == ActivityConst.TYPE_DEFAULT && towInt.getV2() == 1){
									playerRank.isRecv = true;
									break;
								}
							}
							break;
						}
					}
				}
				mergeServerIdList.addAll(MergeMain.getMergeServerIdList(myBatisM));
			}
			//找到新角色id
			MServer oldDatamServer = oldServers.get(0);
			String dbName = MergeMain.createNewDbName("tank", mergeServerIdList);
			
			//jdbc:mysql://localhost:3306/tank_1
			String dbUrl = oldDatamServer.getDbUrl();
			int index = dbUrl.lastIndexOf("/");
			dbUrl = dbUrl.substring(0,index + 1) + dbName;
			
			MServer newServer = new MServer();
			newServer.setServerId(oldDatamServer.getServerId());
			newServer.setUser(oldDatamServer.getUser());
			newServer.setPwd(oldDatamServer.getPwd());
			newServer.setDbUrl(dbUrl);
			
			MyBatisM myBatisM = new MyBatisM(newServer.getDbUrl(), newServer.getUser(), newServer.getPwd());
			
			LordRelationDao lordRelationDao = new LordRelationDao();
			lordRelationDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
			
			Map<Integer, Map<Long, Long>> lordIdServerMap = new HashMap<>();
			for (LordRelation lordRelation : lordRelationDao.selectAllLordRelation()) {
				Map<Long, Long> lordIdMap = lordIdServerMap.get(lordRelation.getOldServerId());
				if(lordIdMap == null){
					lordIdMap = new HashMap<>();
					lordIdServerMap.put(lordRelation.getOldServerId(), lordIdMap);
				}
				lordIdMap.put(lordRelation.getOldLordId(), lordRelation.getNewLordId());
			}
			//替换成新角色id
			for (Entry<Integer, List<PlayerRank>> entry: serverPlayerMap.entrySet()) {
				int serverId = entry.getKey();
				Map<Long, Long> lordIdMap = lordIdServerMap.get(serverId);
				List<PlayerRank> playerRanks = entry.getValue();
				for (PlayerRank playerRank : playerRanks) {
					playerRank.lordId = lordIdMap.get(playerRank.lordId);
				}
				//打印领奖记录
				int rank = 1;
				for (PlayerRank playerRank : playerRanks) {
					LogUtil.error(serverId + "\t" + rank + "\t" + playerRank.lordId + "\t"  + playerRank.score + "\t"  + playerRank.isRecv);
					rank++;
				}
				LogUtil.error(" ");
			}
		}
	}
	
	private static class PartyPlayer{
		Long lordId;
		boolean isRecv;
		
		public PartyPlayer(long lordId) {
			this.lordId = lordId;
		}
	}
	
	private static class PartyRank{
		long build;
		
		List<PartyPlayer> players;
		
		public PartyRank(long build) {
			this.build = build;
			this.players = new ArrayList<>();
		}
	}
	
	private static void select48ActRank() throws Exception {
		Class.forName("com.mysql.jdbc.Driver");
		
		JSONArray serverGroup = readServerList();
		for (int i = 0; i < serverGroup.size(); i++) {
			Map<Integer, List<PartyRank>> serverPartyMap = new HashMap<Integer, List<PartyRank>>();
			List<Integer> mergeServerIdList = new ArrayList<>();
			
			List<MServer> oldServers = JSONArray.parseArray(serverGroup.getJSONArray(i).toString(),MServer.class);
			for (MServer mServer : oldServers) {
				//从旧数据库查询，玩家排行榜数据和领取记录
				MyBatisM myBatisM = new MyBatisM(mServer.getDbUrl(), mServer.getUser(), mServer.getPwd());
				
				ActivityDao activityDao = new ActivityDao();
				activityDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				DataNewDao dataNewDao = new DataNewDao();
				dataNewDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				PartyDao partyDao = new PartyDao();
				partyDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				
				//48活动
				int actId = ActivityConst.ACT_FIRE_SHEET;
				UsualActivity act = null;			
				for (UsualActivity usualActivity : activityDao.selectUsualActivity()) {
					if(usualActivity.getActivityId() == actId){
						act = usualActivity;
						break;
					}
				}
				
				if(act == null){
					continue;
				}
				
				//找出这个服上所有的军团和在军团中的玩家
				Map<Integer, List<PartyMember>> partyMembers = new HashMap<>();
				List<PartyMember> partyMemberList = partyDao.selectParyMemberList();
				for (PartyMember e : partyMemberList) {
					if (e != null) {
						int partyId = e.getPartyId();
						if (partyId != 0) {
							List<PartyMember> list = partyMembers.get(partyId);
							if (list == null) {
								list = new ArrayList<>();
								partyMembers.put(Integer.valueOf(partyId), list);
							}
							list.add(e);
						}
					}
				}
				
				SerActPartyRank ser = SerActPartyRank.parseFrom(act.getPartyRank());
				List<CommonPb.ActPartyRank> list = ser.getActPartyRankList();
				for (CommonPb.ActPartyRank e : list) {
					int partyId = e.getPartyId();
					long build = e.getRankValue();//贡献度
					
					PartyRank partyRank = new PartyRank(build);
					
					List<PartyRank> partyRankList = serverPartyMap.get(mServer.getServerId());
					if(partyRankList == null){
						partyRankList = new ArrayList<>();
						serverPartyMap.put(mServer.getServerId(), partyRankList);
					}
					partyRankList.add(partyRank);
					
					//从旧数据库中查找此军团中所有的玩家id
					List<PartyMember> members = partyMembers.get(partyId);
					for (PartyMember member : members) {
						//判断玩家是否领奖权限
						
						long lordId = member.getLordId();
						PartyPlayer partyPlayer = new PartyPlayer(lordId);
						partyRank.players.add(partyPlayer);
						
						//找到角色看是否领奖
						DataNew dataNew = dataNewDao.selectData(lordId);
						SerData serData = SerData.parseFrom(dataNew.getRoleData());
						List<CommonPb.DbActivity> activityList = serData.getActivityList();
						for (CommonPb.DbActivity ee : activityList) {
							if(ee.getActivityId() == actId){
								for (CommonPb.TwoInt towInt : ee.getTowIntList()) {
									if(towInt.getV1() == 0 && towInt.getV2() == 1){
										partyPlayer.isRecv = true;
										break;
									}
								}
								break;
							}
						}
					}
				}
				mergeServerIdList.addAll(MergeMain.getMergeServerIdList(myBatisM));
			}
			//找到新角色id
			MServer oldDatamServer = oldServers.get(0);
			String dbName = MergeMain.createNewDbName("tank", mergeServerIdList);
			
			//jdbc:mysql://localhost:3306/tank_1
			String dbUrl = oldDatamServer.getDbUrl();
			int index = dbUrl.lastIndexOf("/");
			dbUrl = dbUrl.substring(0,index + 1) + dbName;
			
			MServer newServer = new MServer();
			newServer.setServerId(oldDatamServer.getServerId());
			newServer.setUser(oldDatamServer.getUser());
			newServer.setPwd(oldDatamServer.getPwd());
			newServer.setDbUrl(dbUrl);
			
			MyBatisM myBatisM = new MyBatisM(newServer.getDbUrl(), newServer.getUser(), newServer.getPwd());
			
			LordRelationDao lordRelationDao = new LordRelationDao();
			lordRelationDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
			
			Map<Integer, Map<Long, Long>> lordIdServerMap = new HashMap<>();
			for (LordRelation lordRelation : lordRelationDao.selectAllLordRelation()) {
				Map<Long, Long> lordIdMap = lordIdServerMap.get(lordRelation.getOldServerId());
				if(lordIdMap == null){
					lordIdMap = new HashMap<>();
					lordIdServerMap.put(lordRelation.getOldServerId(), lordIdMap);
				}
				lordIdMap.put(lordRelation.getOldLordId(), lordRelation.getNewLordId());
			}
			//替换成新角色id
			for (Entry<Integer, List<PartyRank>> entry: serverPartyMap.entrySet()) {
				int serverId = entry.getKey();
				Map<Long, Long> lordIdMap = lordIdServerMap.get(serverId);
				List<PartyRank> partyRanks = entry.getValue();
				int rank = 1;
				for (PartyRank partyRank : partyRanks) {
					for (PartyPlayer partyPlayer : partyRank.players) {
						partyPlayer.lordId = lordIdMap.get(partyPlayer.lordId);
						if(partyPlayer.lordId == null){
							continue;//小号被清除
						}
						//打印领奖记录
						LogUtil.error(serverId + "\t" + rank + "\t" + partyPlayer.lordId + "\t"  + partyRank.build + "\t"  + partyPlayer.isRecv);
					}
					
					rank++;
					LogUtil.error("////////");
				}
				LogUtil.error("-------------------------");
			}
		}
	}
	
	private static void select48ActRankNotMerge() throws Exception {
		Class.forName("com.mysql.jdbc.Driver");
		
		JSONArray serverGroup = readServerList();
		for (int i = 0; i < serverGroup.size(); i++) {
			Map<Integer, List<PartyRank>> serverPartyMap = new HashMap<Integer, List<PartyRank>>();
			List<Integer> mergeServerIdList = new ArrayList<>();
			
			List<MServer> oldServers = JSONArray.parseArray(serverGroup.getJSONArray(i).toString(),MServer.class);
			for (MServer mServer : oldServers) {
				//从旧数据库查询，玩家排行榜数据和领取记录
				MyBatisM myBatisM = new MyBatisM(mServer.getDbUrl(), mServer.getUser(), mServer.getPwd());
				
				ActivityDao activityDao = new ActivityDao();
				activityDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				DataNewDao dataNewDao = new DataNewDao();
				dataNewDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				PartyDao partyDao = new PartyDao();
				partyDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				
				//48活动
				int actId = ActivityConst.ACT_FIRE_SHEET;
				UsualActivity act = null;			
				for (UsualActivity usualActivity : activityDao.selectUsualActivity()) {
					if(usualActivity.getActivityId() == actId){
						act = usualActivity;
						break;
					}
				}
				
				if(act == null){
					continue;
				}
				
				//找出这个服上所有的军团和在军团中的玩家
				Map<Integer, List<PartyMember>> partyMembers = new HashMap<>();
				List<PartyMember> partyMemberList = partyDao.selectParyMemberList();
				for (PartyMember e : partyMemberList) {
					if (e != null) {
						int partyId = e.getPartyId();
						if (partyId != 0) {
							List<PartyMember> list = partyMembers.get(partyId);
							if (list == null) {
								list = new ArrayList<>();
								partyMembers.put(Integer.valueOf(partyId), list);
							}
							list.add(e);
						}
					}
				}
				
				SerActPartyRank ser = SerActPartyRank.parseFrom(act.getPartyRank());
				List<CommonPb.ActPartyRank> list = ser.getActPartyRankList();
				for (CommonPb.ActPartyRank e : list) {
					int partyId = e.getPartyId();
					long build = e.getRankValue();//贡献度
					
					PartyRank partyRank = new PartyRank(build);
					
					List<PartyRank> partyRankList = serverPartyMap.get(mServer.getServerId());
					if(partyRankList == null){
						partyRankList = new ArrayList<>();
						serverPartyMap.put(mServer.getServerId(), partyRankList);
					}
					partyRankList.add(partyRank);
					
					//从旧数据库中查找此军团中所有的玩家id
					List<PartyMember> members = partyMembers.get(partyId);
					for (PartyMember member : members) {
						//判断玩家是否领奖权限
						
						long lordId = member.getLordId();
						PartyPlayer partyPlayer = new PartyPlayer(lordId);
						partyRank.players.add(partyPlayer);
						
						//找到角色看是否领奖
						DataNew dataNew = dataNewDao.selectData(lordId);
						SerData serData = SerData.parseFrom(dataNew.getRoleData());
						List<CommonPb.DbActivity> activityList = serData.getActivityList();
						for (CommonPb.DbActivity ee : activityList) {
							if(ee.getActivityId() == actId){
								for (CommonPb.TwoInt towInt : ee.getTowIntList()) {
									if(towInt.getV1() == 0 && towInt.getV2() == 1){
										partyPlayer.isRecv = true;
										break;
									}
								}
								break;
							}
						}
					}
				}
				mergeServerIdList.addAll(MergeMain.getMergeServerIdList(myBatisM));
			}
			
			//打印
			for (Entry<Integer, List<PartyRank>> entry: serverPartyMap.entrySet()) {
				int serverId = entry.getKey();
				List<PartyRank> partyRanks = entry.getValue();
				int rank = 1;
				for (PartyRank partyRank : partyRanks) {
					for (PartyPlayer partyPlayer : partyRank.players) {
						if(partyPlayer.lordId == null){
							continue;//小号被清除
						}
						//打印领奖记录
						LogUtil.error(serverId + "\t" + rank + "\t" + partyPlayer.lordId + "\t"  + partyRank.build + "\t"  + partyPlayer.isRecv);
					}
					
					rank++;
					LogUtil.error("////////");
				}
				LogUtil.error("-------------------------");
			}
		}
	}
	
	private static void select126ActRankNotMerge() throws Exception {
		Class.forName("com.mysql.jdbc.Driver");
		
		JSONArray serverGroup = readServerList();
		for (int i = 0; i < serverGroup.size(); i++) {
			Map<Integer, List<PlayerRank>> serverPlayerMap = new HashMap<Integer, List<PlayerRank>>();
			
			List<MServer> oldServers = JSONArray.parseArray(serverGroup.getJSONArray(i).toString(),MServer.class);
			for (MServer mServer : oldServers) {
				//从旧数据库查询，玩家排行榜数据和领取记录
				MyBatisM myBatisM = new MyBatisM(mServer.getDbUrl(), mServer.getUser(), mServer.getPwd());
				
				ActivityDao activityDao = new ActivityDao();
				activityDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				DataNewDao dataNewDao = new DataNewDao();
				dataNewDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				
				//活动
				int actId = ActivityConst.ACT_GOD_GENERAL_ID;
				UsualActivity act = null;			
				for (UsualActivity usualActivity : activityDao.selectUsualActivity()) {
					if(usualActivity.getActivityId() == actId){
						act = usualActivity;
						break;
					}
				}
				
				if(act == null){
					continue;
				}
				
				SerActPlayerRank ser = SerActPlayerRank.parseFrom(act.getPlayerRank());
				List<CommonPb.ActPlayerRank> list = ser.getActPlayerRankList();
				for (CommonPb.ActPlayerRank e : list) {
					long lordId = e.getLordId();
					long score = e.getRankValue();
					
					PlayerRank playerRank = new PlayerRank(lordId,score);
					
					List<PlayerRank> playerRankList = serverPlayerMap.get(mServer.getServerId());
					if(playerRankList == null){
						playerRankList = new ArrayList<>();
						serverPlayerMap.put(mServer.getServerId(), playerRankList);
					}
					playerRankList.add(playerRank);
					
					//找到角色看是否领奖
					DataNew dataNew = dataNewDao.selectData(lordId);
					SerData serData = SerData.parseFrom(dataNew.getRoleData());
					List<CommonPb.DbActivity> activityList = serData.getActivityList();
					for (CommonPb.DbActivity ee : activityList) {
						if(ee.getActivityId() == actId){
							for (CommonPb.TwoInt towInt : ee.getTowIntList()) {
								if(towInt.getV1() == ActivityConst.TYPE_DEFAULT && towInt.getV2() == 1){
									playerRank.isRecv = true;
									break;
								}
							}
							break;
						}
					}
				}
			}
			
			for (Entry<Integer, List<PlayerRank>> entry: serverPlayerMap.entrySet()) {
				int serverId = entry.getKey();
				List<PlayerRank> playerRanks = entry.getValue();
				//打印领奖记录
				int rank = 1;
				for (PlayerRank playerRank : playerRanks) {
					LogUtil.error(serverId + "\t" + rank + "\t" + playerRank.lordId + "\t"  + playerRank.score + "\t"  + playerRank.isRecv);
					rank++;
				}
				LogUtil.error(" ");
			}
		}
	}
	
	private static void selectActRankNotMerge(int actId) throws Exception {
		Class.forName("com.mysql.jdbc.Driver");
		
		JSONArray serverGroup = readServerList();
		for (int i = 0; i < serverGroup.size(); i++) {
			Map<Integer, List<PlayerRank>> serverPlayerMap = new HashMap<Integer, List<PlayerRank>>();
			
			List<MServer> oldServers = JSONArray.parseArray(serverGroup.getJSONArray(i).toString(),MServer.class);
			for (MServer mServer : oldServers) {
				//从旧数据库查询，玩家排行榜数据和领取记录
				MyBatisM myBatisM = new MyBatisM(mServer.getDbUrl(), mServer.getUser(), mServer.getPwd());
				
				ActivityDao activityDao = new ActivityDao();
				activityDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				DataNewDao dataNewDao = new DataNewDao();
				dataNewDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
				
				//活动
				UsualActivity act = null;			
				for (UsualActivity usualActivity : activityDao.selectUsualActivity()) {
					if(usualActivity.getActivityId() == actId){
						act = usualActivity;
						break;
					}
				}
				
				if(act == null){
					continue;
				}
				
				SerActPlayerRank ser = SerActPlayerRank.parseFrom(act.getPlayerRank());
				List<CommonPb.ActPlayerRank> list = ser.getActPlayerRankList();
				for (CommonPb.ActPlayerRank e : list) {
					long lordId = e.getLordId();
					long score = e.getRankValue();
					
					PlayerRank playerRank = new PlayerRank(lordId,score);
					
					List<PlayerRank> playerRankList = serverPlayerMap.get(mServer.getServerId());
					if(playerRankList == null){
						playerRankList = new ArrayList<>();
						serverPlayerMap.put(mServer.getServerId(), playerRankList);
					}
					playerRankList.add(playerRank);
					
					//找到角色看是否领奖
					DataNew dataNew = dataNewDao.selectData(lordId);
					SerData serData = SerData.parseFrom(dataNew.getRoleData());
					List<CommonPb.DbActivity> activityList = serData.getActivityList();
					for (CommonPb.DbActivity ee : activityList) {
						if(ee.getActivityId() == actId){
							for (CommonPb.TwoInt towInt : ee.getTowIntList()) {
								if(towInt.getV1() == ActivityConst.TYPE_DEFAULT && towInt.getV2() == 1){
									playerRank.isRecv = true;
									break;
								}
							}
							break;
						}
					}
				}
			}
			
			for (Entry<Integer, List<PlayerRank>> entry: serverPlayerMap.entrySet()) {
				int serverId = entry.getKey();
				List<PlayerRank> playerRanks = entry.getValue();
				//打印领奖记录
				int rank = 1;
				for (PlayerRank playerRank : playerRanks) {
					LogUtil.error(serverId + "\t" + rank + "\t" + playerRank.lordId + "\t"  + playerRank.score + "\t"  + playerRank.isRecv);
					rank++;
				}
				LogUtil.error(" ");
			}
		}
	}
	
	public static String selectScoreActRank(String dbUrl,String user,String pwd,int actId) {
		try {
			Class.forName("com.mysql.jdbc.Driver");
			
			//从旧数据库查询，玩家排行榜数据和领取记录
			MyBatisM myBatisM = new MyBatisM(dbUrl, user, pwd);
			
			ActivityDao activityDao = new ActivityDao();
			activityDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
			DataNewDao dataNewDao = new DataNewDao();
			dataNewDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
			LordDao lordDao = new LordDao();
			lordDao.setSqlSessionFactory(myBatisM.getSqlSessionFactory());
			
			//活动
			UsualActivity act = null;			
			for (UsualActivity usualActivity : activityDao.selectUsualActivity()) {
				if(usualActivity.getActivityId() == actId){
					act = usualActivity;
					break;
				}
			}
			
			if(act == null){
				return null;
			}
			
			List<PlayerRank> playerRankList = new ArrayList<>();
			
			SerActPlayerRank ser = SerActPlayerRank.parseFrom(act.getPlayerRank());
			List<CommonPb.ActPlayerRank> list = ser.getActPlayerRankList();
			for (CommonPb.ActPlayerRank e : list) {
				long lordId = e.getLordId();
				long score = e.getRankValue();
				
				PlayerRank playerRank = new PlayerRank(lordId,score);
				
				playerRankList.add(playerRank);
				
				//找到角色看是否领奖
				DataNew dataNew = dataNewDao.selectData(lordId);
				SerData serData = SerData.parseFrom(dataNew.getRoleData());
				List<CommonPb.DbActivity> activityList = serData.getActivityList();
				for (CommonPb.DbActivity ee : activityList) {
					if(ee.getActivityId() == actId){
						for (CommonPb.TwoInt towInt : ee.getTowIntList()) {
							if(towInt.getV1() == ActivityConst.TYPE_DEFAULT && towInt.getV2() == 1){
								playerRank.isRecv = true;
								break;
							}
						}
						break;
					}
				}
				
				Lord lord = lordDao.selectLordById(lordId);
				if(lord != null){
					playerRank.name = lord.getNick();
				}
			}
			
			return JSONObject.toJSONString(playerRankList);
		} catch (Exception e) {
			return null;
		}
	}

}
