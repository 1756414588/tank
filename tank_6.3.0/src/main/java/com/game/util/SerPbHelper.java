package com.game.util;

import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.airship.Airship;
import com.game.domain.p.airship.AirshipTeam;
import com.game.domain.p.airship.PlayerAirship;
import com.game.domain.p.airship.RecvAirshipProduceAwardRecord;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.p.lordequip.LordEquipBuilding;
import com.game.domain.p.lordequip.LordEquipMatBuilding;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.TwoInt;
import com.game.pb.SerializePb.*;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: SerPbHelper
 * @Description: 序列化PB的工具类
 * @date 2017/4/14 10:59
 */
public final class SerPbHelper {

	/**
	 * 反序列化攻击特效
	 *
	 * @param player
	 * @param serData
	 */
	public static void dserAttackEffect(Player player, SerData serData) {
		List<CommonPb.AttackEffectPb> list = serData.getAtkEftList();
		for (CommonPb.AttackEffectPb effectPb : list) {
			player.atkEffects.put(effectPb.getType(), new AttackEffect(effectPb));
		}
	}

	/**
	 * 序列化攻击特效
	 *
	 * @param player
	 * @param ser
	 */
	public static void serAttackEffect(Player player, SerData.Builder ser) {
		for (Map.Entry<Integer, AttackEffect> entry : player.atkEffects.entrySet()) {
			ser.addAtkEft(PbHelper.createAttackEffectPb(entry.getValue()));
		}
	}

	/**
	 * 反序列化秘密武器
	 *
	 * @param player
	 * @param serData
	 */
	public static void dserSecretWeapon(Player player, SerData serData) {
		List<CommonPb.SecretWeapon> weaponList = serData.getWeaponList();
		if (weaponList != null && !weaponList.isEmpty()) {
			for (CommonPb.SecretWeapon pbWeapon : weaponList) {
				SecretWeapon weapon = new SecretWeapon(pbWeapon);
				player.secretWeaponMap.put(weapon.getId(), weapon);
			}
		}
	}

	/**
	 * 序列化秘密武器
	 *
	 * @param ser
	 * @param secretWeaponMap
	 */
	public static void serSecretWeapon(SerData.Builder ser, Map<Integer, SecretWeapon> secretWeaponMap) {
		for (Map.Entry<Integer, SecretWeapon> entry : secretWeaponMap.entrySet()) {
			ser.addWeapon(PbHelper.createSecretWeapon(entry.getValue()));
		}
	}

	/**
	 * 序列化飞艇信息
	 *
	 * @param airshipMap
	 * @return
	 */
	public static byte[] serAirship(Map<Integer, Airship> airshipMap, Map<Long, PlayerAirship> playerAirshipMap) {
		SerAirship.Builder ser = SerAirship.newBuilder();
		for (Map.Entry<Integer, Airship> entry : airshipMap.entrySet()) {
			AirshipDb.Builder pbAirship = AirshipDb.newBuilder();
			Airship airship = entry.getValue();
			pbAirship.setId(airship.getId());
			pbAirship.setPartyId(airship.getPartyId());
			pbAirship.setSafeEndTime(airship.getSafeEndTime());
			pbAirship.setProduceTime(airship.getProduceTime());
			pbAirship.setProduceNum(airship.getProduceNum());
			pbAirship.setDurability(airship.getDurability());
			pbAirship.setRuins(airship.isRuins());
			pbAirship.setOccupyTime(airship.getOccupyTime());

			// 序列化征收记录
			for (RecvAirshipProduceAwardRecord r : airship.getRecvRecordList()) {
				SaveRecvRecord.Builder recordPb = SaveRecvRecord.newBuilder();
				recordPb.setLordId(r.getLordId());
				recordPb.setType(r.getType());
				recordPb.setAwardId(r.getAwardId());
				recordPb.setCount(r.getCount());
				recordPb.setRecvTime(r.getTimeSec());
				recordPb.setMplt(r.getMplt());
				pbAirship.addRecvRecords(recordPb.build());
			}

			ser.addAirship(pbAirship);
		}
		if (!playerAirshipMap.isEmpty()) {
			for (Map.Entry<Long, PlayerAirship> airshipEntry : playerAirshipMap.entrySet()) {
				PlayerAirship playerAirship = airshipEntry.getValue();
				SerPlayerAirship.Builder pbPlayerAirship = SerPlayerAirship.newBuilder();
				pbPlayerAirship.setLordId(airshipEntry.getKey());
				pbPlayerAirship.setFreeCnt(playerAirship.getFreeCrtCount());
				pbPlayerAirship.setFreeDay(playerAirship.getFreeCrtDay());
				for (Map.Entry<Integer, Integer> scoutEntry : playerAirship.getScoutMap().entrySet()) {
					CommonPb.Kv.Builder kvb = CommonPb.Kv.newBuilder();
					kvb.setKey(scoutEntry.getKey());
					kvb.setValue(scoutEntry.getValue());
					pbPlayerAirship.addScout(kvb);
				}
				ser.addPlayerAirship(pbPlayerAirship);
			}
		}
		return ser.build().toByteArray();
	}

	/**
	 * 序列化飞艇队伍信息
	 *
	 * @param airshipTeam
	 * @return
	 */
	public static AirshipTeamDb createAirshipTeam(AirshipTeam airshipTeam) {
		AirshipTeamDb.Builder builder = AirshipTeamDb.newBuilder();
		builder.setId(airshipTeam.getId());
		builder.setLordId(airshipTeam.getLordId());
		builder.setState(airshipTeam.getState());
		builder.setEndTime(airshipTeam.getEndTime());
		for (Army army : airshipTeam.getArmys()) {
			builder.addArmys(PbHelper.createTwoLongPb(army.player.roleId, army.getKeyId()));
		}
		return builder.build();
	}

	/**
	 * 序列化世界地图矿点信息
	 *
	 * @param mineMap
	 * @return
	 */
	public static byte[] serWorldMine(Map<Integer, Mine> mineMap) {
		SerWorldMine.Builder builder = SerWorldMine.newBuilder();
		if (mineMap != null && !mineMap.isEmpty()) {
			for (Map.Entry<Integer, Mine> entry : mineMap.entrySet()) {
				Mine mine = entry.getValue();
				SerMine.Builder serMineBuilder = SerMine.newBuilder();
				serMineBuilder.setMine(PbHelper.createMinePb2(mine, 0,null));
				serMineBuilder.setModTime(mine.getModTime());
				if (!mine.getScoutMap().isEmpty()) {
					SerMineScout.Builder scoutBuilder = SerMineScout.newBuilder();
					for (Map.Entry<Long, Integer> scoutEntry : mine.getScoutMap().entrySet()) {
						scoutBuilder.setLordId(scoutEntry.getKey());
						scoutBuilder.setScoutTime(scoutEntry.getValue());
						serMineBuilder.addScout(scoutBuilder);
						scoutBuilder.clear();
					}
				}
				builder.addMine(serMineBuilder);
				serMineBuilder.clear();
			}
		}
		return builder.build().toByteArray();
	}

	/**
	 * 反序列化世界地图矿点信息
	 *
	 * @param data
	 * @throws InvalidProtocolBufferException
	 */
	public static Map<Integer, Mine> dserWorldMine(byte[] data) throws InvalidProtocolBufferException {
		Map<Integer, Mine> mineMap = new HashMap<>();
		if (data == null)
			return mineMap;
		try {
			SerWorldMine serMine = SerWorldMine.parseFrom(data);
			for (SerMine pbMine : serMine.getMineList()) {
				Mine mine = new Mine();
				mine.setMineId(pbMine.getMine().getMineId());
				mine.setMineLv(pbMine.getMine().getMineLv());
				mine.setPos(pbMine.getMine().getPos());
				mine.setQua(pbMine.getMine().getQua());
				mine.setQuaExp(pbMine.getMine().getQuaExp());
				mine.setModTime(pbMine.getModTime());
				if (pbMine.getScoutList() != null && !pbMine.getScoutList().isEmpty()) {
					for (SerMineScout pbScout : pbMine.getScoutList()) {
						mine.getScoutMap().put(pbScout.getLordId(), pbScout.getScoutTime());
					}
				}
				mineMap.put(mine.getPos(), mine);
			}
		} catch (InvalidProtocolBufferException e) {
			// 兼容老数据
			return dserWorldMineOldData(data);
		}
		return mineMap;
	}

	private static Map<Integer, Mine> dserWorldMineOldData(byte[] data) throws InvalidProtocolBufferException {
		Map<Integer, Mine> mineMap = new HashMap<>();
		CommonPb.WorldMineInfo mineInfo = null;
		mineInfo = CommonPb.WorldMineInfo.parseFrom(data);
		List<CommonPb.Mine> infoList = mineInfo.getMineList();
		if (infoList != null && !infoList.isEmpty()) {
			for (com.game.pb.CommonPb.Mine pMine : infoList) {
				Mine mine = new Mine();
				mine.setMineId(pMine.getMineId());
				mine.setMineLv(pMine.getMineLv());
				mine.setPos(pMine.getPos());
				mine.setQua(pMine.getQua());
				mine.setQuaExp(pMine.getQuaExp());
				mine.setModTime(pMine.getScoutTime());
				mineMap.put(mine.getPos(), mine);
			}
		}
		return mineMap;
	}

	/**
	 * 序列化每月签到
	 *
	 * @param monthSign
	 * @return
	 */
	public static SerMonthSign serMonthSign(MonthSign monthSign) {
		SerMonthSign.Builder builder = SerMonthSign.newBuilder();
		builder.setDays(monthSign.getDays());
		builder.setTodaySign(monthSign.getTodaySign());
		builder.setSignTime(monthSign.getSignMonth() * 100 + monthSign.getSignDay());
		builder.addAllDayExt(monthSign.getExt());
		return builder.build();
	}

	/**
	 * 序列化作战研究院
	 *
	 * @param labInfo
	 * @return
	 */
	public static CommonPb.LabInfoPb serLabInfoPb(LabInfo labInfo) {
		CommonPb.LabInfoPb.Builder builder = CommonPb.LabInfoPb.newBuilder();

		Map<Integer, Integer> labItemInfo = labInfo.getLabItemInfo();
		for (Map.Entry<Integer, Integer> en : labItemInfo.entrySet()) {
			builder.addLabItemInfo(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));
		}

		Map<Integer, Integer> archInfo = labInfo.getArchInfo();
		for (Map.Entry<Integer, Integer> en : archInfo.entrySet()) {
			builder.addArchInfo(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));
		}

		Map<Integer, Integer> techInfo = labInfo.getTechInfo();
		for (Map.Entry<Integer, Integer> en : techInfo.entrySet()) {
			builder.addTechInfo(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));
		}

		Map<Integer, Integer> personInfo = labInfo.getPersonInfo();
		for (Map.Entry<Integer, Integer> en : personInfo.entrySet()) {
			builder.addPersonInfo(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));
		}

		Map<Integer, Integer> resourceInfo = labInfo.getResourceInfo();
		for (Map.Entry<Integer, Integer> en : resourceInfo.entrySet()) {
			builder.addResourceInfo(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));
		}

		List<Integer> rewardInfo = labInfo.getRewardInfo();
		for (Integer id : rewardInfo) {
			builder.addRewardInfo(id);
		}

		Map<Integer, Map<Integer, Integer>> graduateInfo = labInfo.getGraduateInfo();

		for (Map.Entry<Integer, Map<Integer, Integer>> en : graduateInfo.entrySet()) {
			CommonPb.GraduateInfoPb.Builder info = CommonPb.GraduateInfoPb.newBuilder();
			info.setType(en.getKey());
			Map<Integer, Integer> v = en.getValue();

			for (Map.Entry<Integer, Integer> e : v.entrySet()) {
				info.addGraduateInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
			}
			builder.addGraduateInfo(info);
		}

		Map<Integer, LabProductionInfo> labProMap = labInfo.getLabProMap();
		for (LabProductionInfo info : labProMap.values()) {
			builder.addProInfo(PbHelper.createThreePb(info.getResourceId(), info.getState(), info.getTime()));
		}

		Map<Integer, SpyInfoData> spyMap = labInfo.getSpyMap();
		if (!spyMap.isEmpty()) {

			for (SpyInfoData spy : spyMap.values()) {
				CommonPb.SpyInfo.Builder info = CommonPb.SpyInfo.newBuilder();
				info.setAreaId(spy.getAreaId());
				info.setState(spy.getState());
				info.setTaskId(spy.getTaskId());
				info.setTime(spy.getTime());
				info.setSpyId(spy.getSpyId());
				builder.addSpyInfo(info);
			}
		}

		return builder.build();
	}

	public static CommonPb.RedPlanInfo serRedPlanInfo(RedPlanInfo info) {
		CommonPb.RedPlanInfo.Builder builder = CommonPb.RedPlanInfo.newBuilder();

		builder.setFuel(info.getFuel());
		builder.setVersion(info.getVersion());
		builder.setBuyTime(info.getBuyTime());
		builder.setNowAreaId(info.getNowAreaId());
		builder.setNowPointId(info.getNowPointId());
		builder.setFuelTime(info.getFuelTime());

		Map<Integer, List<Integer>> pointInfo = info.getPointInfo();
		for (Map.Entry<Integer, List<Integer>> e : pointInfo.entrySet()) {
			List<Integer> value = e.getValue();
			for (Integer pointId : value) {
				builder.addPointInfo(PbHelper.createTwoIntPb(e.getKey(), pointId));
			}
		}

		List<Integer> rewardInfo = info.getRewardInfo();
		for (Integer areaId : rewardInfo) {
			builder.addRewardInfo(areaId);
		}

		builder.setItemCount(0);

		Map<Integer, Integer> shopInfo = info.getShopInfo();
		for (Map.Entry<Integer, Integer> e : shopInfo.entrySet()) {
			builder.addShopInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}

		builder.setFuelBuyCount(info.getFuelCount());

		Map<Integer, List<Integer>> linePointInfo = info.getLinePointInfo();
		for (Map.Entry<Integer, List<Integer>> e : linePointInfo.entrySet()) {
			List<Integer> value = e.getValue();
			for (Integer pointId : value) {
				builder.addLinePointInfo(PbHelper.createTwoIntPb(e.getKey(), pointId));
			}
		}

		return builder.build();

	}

	public static void serGuideInfo(SerData.Builder serData, List<Integer> info) {
		for (Integer e : info) {
			serData.addGuideRewardInfo(e);
		}
	}

	public static List<Integer> dserLabInfo(SerData serData) {

		List<Integer> arrayList = new ArrayList<>();
		List<Integer> infoList = serData.getGuideRewardInfoList();
		if (infoList != null && !infoList.isEmpty()) {
			for (Integer io : infoList) {
				arrayList.add(io);
			}
		}
		return arrayList;
	}

	/**
	 * 反序列化每月签到信息
	 *
	 * @param data
	 * @return
	 * @throws InvalidProtocolBufferException
	 */
	public static MonthSign deserMonthSign(SerData serdata) {
		MonthSign monthSign = new MonthSign();
		SerMonthSign pbMonthSign = serdata.getMonthSign();
		monthSign.setDays(pbMonthSign.getDays());
		monthSign.setTodaySign(pbMonthSign.getTodaySign());
		monthSign.setSignMonth(pbMonthSign.getSignTime() / 100);
		monthSign.setSignDay(pbMonthSign.getSignTime() % 100);
		monthSign.getExt().addAll(pbMonthSign.getDayExtList());
		return monthSign;
	}

	/**
	 * 反序列化作战研究院
	 *
	 * @param serdata
	 * @return
	 */
	public static LabInfo deserLabInfo(SerData serdata) {
		LabInfo labInfo = new LabInfo();

		CommonPb.LabInfoPb labInfoPb = serdata.getLabInfo();

		List<TwoInt> labItemInfo = labInfoPb.getLabItemInfoList();
		if (labItemInfo != null && !labItemInfo.isEmpty()) {
			Map<Integer, Integer> labItemInfoMap = new HashMap<>();
			for (TwoInt t : labItemInfo) {
				labItemInfoMap.put(t.getV1(), t.getV2());
			}
			labInfo.setLabItemInfo(labItemInfoMap);
		}

		List<TwoInt> archInfo = labInfoPb.getArchInfoList();
		if (archInfo != null && !archInfo.isEmpty()) {
			Map<Integer, Integer> archInfoMap = new HashMap<>();
			for (TwoInt t : archInfo) {
				archInfoMap.put(t.getV1(), t.getV2());
			}
			labInfo.setArchInfo(archInfoMap);
		}

		List<TwoInt> techInfo = labInfoPb.getTechInfoList();
		if (techInfo != null && !techInfo.isEmpty()) {
			Map<Integer, Integer> techInfoMap = new HashMap<>();
			for (TwoInt t : techInfo) {
				techInfoMap.put(t.getV1(), t.getV2());
			}
			labInfo.setTechInfo(techInfoMap);
		}

		List<TwoInt> personInfo = labInfoPb.getPersonInfoList();
		if (personInfo != null && !personInfo.isEmpty()) {
			Map<Integer, Integer> personInfoMap = new HashMap<>();
			for (TwoInt t : personInfo) {
				personInfoMap.put(t.getV1(), t.getV2());
			}
			labInfo.setPersonInfo(personInfoMap);
		}

		List<TwoInt> resourceInfo = labInfoPb.getResourceInfoList();
		if (resourceInfo != null && !resourceInfo.isEmpty()) {
			Map<Integer, Integer> resourceInfoMap = new HashMap<>();
			for (TwoInt t : resourceInfo) {
				resourceInfoMap.put(t.getV1(), t.getV2());
			}
			labInfo.setResourceInfo(resourceInfoMap);
		}

		ArrayList<Integer> rewardInfo = new ArrayList<>(labInfoPb.getRewardInfoList());
		labInfo.setRewardInfo(rewardInfo);

		List<CommonPb.GraduateInfoPb> graduateInfoList = labInfoPb.getGraduateInfoList();
		if (graduateInfoList != null && !graduateInfoList.isEmpty()) {

			Map<Integer, Map<Integer, Integer>> infoMap = new HashMap<>();

			for (CommonPb.GraduateInfoPb t : graduateInfoList) {
				int type = t.getType();
				infoMap.put(type, new HashMap<Integer, Integer>());
				List<TwoInt> info = t.getGraduateInfoList();
				for (TwoInt i : info) {
					infoMap.get(type).put(i.getV1(), i.getV2());
				}
			}

			labInfo.setGraduateInfo(infoMap);
		}

		List<CommonPb.ThreeInt> proInfoList = labInfoPb.getProInfoList();
		Map<Integer, LabProductionInfo> labProMap = new HashMap<>();
		for (CommonPb.ThreeInt info : proInfoList) {
			labProMap.put(info.getV1(), new LabProductionInfo(info.getV1(), info.getV2(), info.getV3()));
		}
		labInfo.setLabProMap(labProMap);

		List<CommonPb.SpyInfo> spyInfoList = labInfoPb.getSpyInfoList();
		if (spyInfoList != null && !spyInfoList.isEmpty()) {
			for (CommonPb.SpyInfo spy : spyInfoList) {
				SpyInfoData spyInfo = new SpyInfoData();
				spyInfo.setAreaId(spy.getAreaId());
				spyInfo.setState(spy.getState());
				spyInfo.setTaskId(spy.getTaskId());
				spyInfo.setTime(spy.getTime());
				spyInfo.setSpyId(spy.getSpyId());
				labInfo.getSpyMap().put(spy.getAreaId(), spyInfo);
			}
		}

		return labInfo;
	}

	public static RedPlanInfo deserRedPlanInfo(SerData serdata) {
		RedPlanInfo info = new RedPlanInfo();
		CommonPb.RedPlanInfo redPlanInfo = serdata.getRedPlanInfo();
		info.setFuel(redPlanInfo.getFuel());
		info.setVersion(redPlanInfo.getVersion());
		info.setBuyTime(redPlanInfo.getBuyTime());
		info.setNowAreaId(redPlanInfo.getNowAreaId());
		info.setNowPointId(redPlanInfo.getNowPointId());
		info.setFuelTime(redPlanInfo.getFuelTime());
		List<TwoInt> pointInfoList = redPlanInfo.getPointInfoList();
		for (TwoInt t : pointInfoList) {
			if (!info.getPointInfo().containsKey(t.getV1())) {
				info.getPointInfo().put(t.getV1(), new ArrayList<Integer>());
			}
			info.getPointInfo().get(t.getV1()).add(t.getV2());
		}

		List<Integer> rewardInfoList = redPlanInfo.getRewardInfoList();
		for (Integer areaId : rewardInfoList) {
			info.getRewardInfo().add(areaId);
		}

		List<TwoInt> shopInfoList = redPlanInfo.getShopInfoList();
		for (TwoInt t : shopInfoList) {
			info.getShopInfo().put(t.getV1(), t.getV2());
		}

		info.setFuelCount(redPlanInfo.getFuelBuyCount());

		List<TwoInt> linePointInfoList = redPlanInfo.getLinePointInfoList();
		for (TwoInt t : linePointInfoList) {
			if (!info.getLinePointInfo().containsKey(t.getV1())) {
				info.getLinePointInfo().put(t.getV1(), new ArrayList<Integer>());
			}
			info.getLinePointInfo().get(t.getV1()).add(t.getV2());
		}

		return info;

	}

	/**
	 * 序列化军备信息
	 *
	 * @param player
	 * @param serData
	 */
	public static void serLordEquipInfo(Player player, SerData.Builder serData) {
		SerLordEquipInfo.Builder builder = SerLordEquipInfo.newBuilder();
		if (!player.leqInfo.getPutonLordEquips().isEmpty()) {
			for (Map.Entry<Integer, LordEquip> entry : player.leqInfo.getPutonLordEquips().entrySet()) {
				builder.addPutOn(PbHelper.createLordEquip(entry.getValue()));
			}
		}

		if (!player.leqInfo.getStoreLordEquips().isEmpty()) {
			for (Map.Entry<Integer, LordEquip> entry : player.leqInfo.getStoreLordEquips().entrySet()) {
				builder.addStore(PbHelper.createLordEquip(entry.getValue()));
			}
		}

		if (!player.leqInfo.getLeqMat().isEmpty()) {
			for (Map.Entry<Integer, Prop> entry : player.leqInfo.getLeqMat().entrySet()) {
				builder.addProp(PbHelper.createPropPb(entry.getValue()));
			}
		}

		builder.setFreeChangeNum(player.leqInfo.getFreeChangeNum());
		builder.setChangeTimeSec(player.leqInfo.getChangeTimeSec());

		builder.setEmployTechId(player.leqInfo.getEmployTechId());
		builder.setEmployEndTime(player.leqInfo.getEmployEndTime());
		builder.setUnlockTechMax(player.leqInfo.getUnlock_tech_max());
		builder.setFree(player.leqInfo.isFree());
		if (!player.leqInfo.getLeq_que().isEmpty()) {
			builder.setLeqb(PbHelper.createLordEquipBuilding(player.leqInfo.getLeq_que().get(0)));
		}

		// 生产材料相关
		builder.setBuyMatCount(player.leqInfo.getBuyMatCount());
		if (!player.leqInfo.getLeq_mat_que().isEmpty()) {
			for (LordEquipMatBuilding building : player.leqInfo.getLeq_mat_que()) {
				builder.addMatQue(createSerLeqMatBuilding(building));
			}
		}
		serData.setLordEquipInfo(builder);
	}

	/**
	 * 反序列化军备信息
	 *
	 * @param player
	 * @param serData
	 */
	public static void deserLordEquipInfo(Player player, SerData serData) {
		SerLordEquipInfo pbData = serData.getLordEquipInfo();
		if (pbData != null) {
			List<Integer> skillLv;
			List<CommonPb.LordEquip> putOnList = pbData.getPutOnList();
			if (putOnList != null && !putOnList.isEmpty()) {
				for (CommonPb.LordEquip pb : putOnList) {
					LordEquip leq = new LordEquip(pb.getKeyId(), pb.getEquipId(), pb.getPos());
					leq.setLock(pb.getIsLock());
					leq.setLordEquipSaveType(pb.getLordEquipSaveType());
					// 反序列化军备技能
					List<TwoInt> skillLvList = pb.getSkillLvList();
					List<List<Integer>> lordEquipSkillList = leq.getLordEquipSkillList();
					for (TwoInt twoInt : skillLvList) {
						skillLv = new ArrayList<Integer>();
						skillLv.add(twoInt.getV1());
						skillLv.add(twoInt.getV2());
						lordEquipSkillList.add(skillLv);
					}


					List<TwoInt> skillLvListSecond = pb.getSkillLvSecondList();
					List<List<Integer>> lordEquipSkillSecond  = leq.getLordEquipSkillSecondList();
					for (TwoInt twoInt : skillLvListSecond) {
						List<Integer> map = new ArrayList<Integer>();
						map.add(twoInt.getV1());
						map.add(twoInt.getV2());
						lordEquipSkillSecond.add(map);
					}

					player.leqInfo.getPutonLordEquips().put(leq.getPos(), leq);
				}
			}

			List<CommonPb.LordEquip> storeList = pbData.getStoreList();
			if (storeList != null && !storeList.isEmpty()) {
				for (CommonPb.LordEquip pb : storeList) {
					LordEquip leq = new LordEquip(pb.getKeyId(), pb.getEquipId(), pb.getPos());
					leq.setLock(pb.getIsLock());
					leq.setLordEquipSaveType(pb.getLordEquipSaveType());

					// 反序列化军备技能
					List<TwoInt> skillLvList = pb.getSkillLvList();
					List<List<Integer>> lordEquipSkillList = leq.getLordEquipSkillList();
					for (TwoInt twoInt : skillLvList) {
						skillLv = new ArrayList<Integer>();
						skillLv.add(twoInt.getV1());
						skillLv.add(twoInt.getV2());
						lordEquipSkillList.add(skillLv);
					}


					// 反序列化军备技能
					List<TwoInt> skillLvSecondList = pb.getSkillLvSecondList();
					List<List<Integer>> lordEquipSkillSecondList = leq.getLordEquipSkillSecondList();
					for (TwoInt twoInt : skillLvSecondList) {
						List<Integer> map = new ArrayList<Integer>();
						map.add(twoInt.getV1());
						map.add(twoInt.getV2());
						lordEquipSkillSecondList.add(map);
					}


					player.leqInfo.getStoreLordEquips().put(leq.getKeyId(), leq);
				}
			}

			List<CommonPb.Prop> propList = pbData.getPropList();
			if (propList != null && !propList.isEmpty()) {
				for (CommonPb.Prop pb : propList) {
					Prop prop = new Prop(pb.getPropId(), pb.getCount());
					player.leqInfo.getLeqMat().put(prop.getPropId(), prop);
				}
			}

			player.leqInfo.setEmployTechId(pbData.getEmployTechId());
			player.leqInfo.setEmployEndTime(pbData.getEmployEndTime());
			player.leqInfo.setFree(pbData.getFree());

			player.leqInfo.setChangeTimeSec(pbData.getChangeTimeSec());
			player.leqInfo.setFreeChangeNum(pbData.getFreeChangeNum());

			CommonPb.LordEquipBuilding pbb = pbData.getLeqb();
			if (pbb != null && pbb.getEquipId() > 0) {
				LordEquipBuilding building = new LordEquipBuilding(pbb.getEquipId(), pbb.getPeriod(), pbb.getEndTime());
				building.setTechId(pbb.getTechId());
				player.leqInfo.getLeq_que().add(building);
			}

			if (pbData.getUnlockTechMax() > 0) {
				player.leqInfo.setUnlock_tech_max(pbData.getUnlockTechMax());
			}

			// 生产材料相关
			player.leqInfo.setBuyMatCount(pbData.getBuyMatCount());
			List<SerLeqMatBuilding> pbMat_que = pbData.getMatQueList();
			if (pbMat_que != null && !pbMat_que.isEmpty()) {
				for (SerLeqMatBuilding pbMb : pbMat_que) {
					CommonPb.LeqMatBuilding lemb = pbMb.getLemb();
					LordEquipMatBuilding building = new LordEquipMatBuilding(lemb.getPid(), lemb.getCount(),
							lemb.getPeriod());
					building.setComplete(lemb.getComplete());
					building.setEndTime(lemb.getEndTime());
					building.setLastTime(pbMb.getLastTime());
					building.setSpeed(pbMb.getSpeed());
					player.leqInfo.getLeq_mat_que().add(building);
				}
				Collections.sort(player.leqInfo.getLeq_mat_que());
			}
		}
	}

	/**
	 * 创建军备材料生产domain的序列化对象
	 *
	 * @param building
	 * @return SerLeqMatBuilding
	 */
	private static SerLeqMatBuilding createSerLeqMatBuilding(LordEquipMatBuilding building) {
		SerLeqMatBuilding.Builder pbb = SerLeqMatBuilding.newBuilder();
		pbb.setLemb(PbHelper.createLordEquipMatBuilding(building));
		pbb.setLastTime(building.getLastTime());
		pbb.setSpeed(building.getSpeed());
		return pbb.build();
	}

	public static void serFestivalInfo(SerData.Builder serData, FestivalInfo festivalInfo) {

		CommonPb.FestivalInfo.Builder builder = CommonPb.FestivalInfo.newBuilder();

		builder.setLoginRewardState(festivalInfo.getLoginState());
		builder.setLoginTime(festivalInfo.getLoginTime());
		builder.setVersion(festivalInfo.getVersion());
		for (Map.Entry<Integer, Integer> e : festivalInfo.getCount().entrySet()) {
			builder.addCountInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));

		}
		serData.setFestivalInfo(builder.build());
	}

	public static FestivalInfo derFestivalInfo(SerData data) {

		FestivalInfo f = new FestivalInfo();

		CommonPb.FestivalInfo festivalInfo = data.getFestivalInfo();
		f.setLoginState(festivalInfo.getLoginRewardState());
		f.setLoginTime(festivalInfo.getLoginTime());
		f.setVersion(festivalInfo.getVersion());
		List<TwoInt> countInfoList = festivalInfo.getCountInfoList();

		if (countInfoList != null && !countInfoList.isEmpty()) {
			for (TwoInt t : countInfoList) {
				f.getCount().put(t.getV1(), t.getV2());
			}
		}
		return f;
	}

	public static void serLuckyInfo(SerData.Builder serData, LuckyInfo luckyInfo) {
		CommonPb.LuckyInfo.Builder builder = CommonPb.LuckyInfo.newBuilder();
		builder.setRecharge(luckyInfo.getRecharge());
		builder.setUseLuckyCount(luckyInfo.getUseLuckyCount());
		builder.setVersion(luckyInfo.getVersion());
		serData.setLuckyInfo(builder.build());
	}

	public static LuckyInfo derLuckyInfo(SerData data) {
		CommonPb.LuckyInfo luckyInfo = data.getLuckyInfo();
		LuckyInfo l = new LuckyInfo();
		l.setRecharge(luckyInfo.getRecharge());
		l.setUseLuckyCount(luckyInfo.getUseLuckyCount());
		l.setVersion(luckyInfo.getVersion());
		return l;
	}

	public static void serTeamInstanceInfo(SerData.Builder serData, TeamInstanceInfo teamInstanceInfo) {

		CommonPb.TeamInstanceInfo.Builder builder = CommonPb.TeamInstanceInfo.newBuilder();
		builder.setTime(teamInstanceInfo.getTime());
		builder.setBounty(teamInstanceInfo.getBounty());
		builder.setDayItemCount(teamInstanceInfo.getDayItemCount());

		Map<Integer, Integer> countInfo = teamInstanceInfo.getCountInfo();
		for (Map.Entry<Integer, Integer> e : countInfo.entrySet()) {
			builder.addCountInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}

		Map<Integer, Integer> rewardInfo = teamInstanceInfo.getRewardInfo();
		for (Map.Entry<Integer, Integer> e : rewardInfo.entrySet()) {
			builder.addRewardInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}

		Map<Integer, Integer> taskInfo = teamInstanceInfo.getTaskInfo();
		for (Map.Entry<Integer, Integer> e : taskInfo.entrySet()) {
			builder.addTaskInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}

		Map<Integer, Integer> taskRewardState = teamInstanceInfo.getTaskRewardState();
		for (Map.Entry<Integer, Integer> e : taskRewardState.entrySet()) {
			builder.addTaskRewardState(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}

		serData.setTeamInstanceInfo(builder.build());

	}

	public static TeamInstanceInfo derTeamInstanceInfo(SerData data) {

		CommonPb.TeamInstanceInfo teamInstanceInfo = data.getTeamInstanceInfo();

		TeamInstanceInfo team = new TeamInstanceInfo();
		team.setTime(teamInstanceInfo.getTime());
		team.setBounty(teamInstanceInfo.getBounty());
		team.setDayItemCount(teamInstanceInfo.getDayItemCount());

		List<TwoInt> countInfoList = teamInstanceInfo.getCountInfoList();
		if (countInfoList != null && !countInfoList.isEmpty()) {
			for (TwoInt t : countInfoList) {
				team.getCountInfo().put(t.getV1(), t.getV2());
			}
		}

		List<TwoInt> rewardInfoList = teamInstanceInfo.getRewardInfoList();
		if (rewardInfoList != null && !rewardInfoList.isEmpty()) {
			for (TwoInt t : rewardInfoList) {
				team.getRewardInfo().put(t.getV1(), t.getV2());
			}
		}

		List<TwoInt> taskInfoList = teamInstanceInfo.getTaskInfoList();
		if (taskInfoList != null && !taskInfoList.isEmpty()) {
			for (TwoInt t : taskInfoList) {
				team.getTaskInfo().put(t.getV1(), t.getV2());
			}
		}

		List<TwoInt> taskRewardStateList = teamInstanceInfo.getTaskRewardStateList();
		if (taskRewardStateList != null && !taskRewardStateList.isEmpty()) {
			for (TwoInt t : taskRewardStateList) {
				team.getTaskRewardState().put(t.getV1(), t.getV2());
			}
		}

		return team;
	}

	public static void serEnergyDialDayInfo(SerData.Builder serData, DialDailyGoalInfo energyInfo) {
		CommonPb.DialDailyGoalInfo.Builder builder = CommonPb.DialDailyGoalInfo.newBuilder();
		builder.setCount(energyInfo.getCount());
		builder.setLastDay(energyInfo.getLastDay());
		Map<Integer, Integer> status = energyInfo.getRewardStatus();
		for (Map.Entry<Integer, Integer> e : status.entrySet()) {
			builder.addRewardStatus(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}
		serData.setEnergyInfo(builder.build());
	}

	public static DialDailyGoalInfo dserEnergyDialDayInfo(SerData data) {
		CommonPb.DialDailyGoalInfo energyInfo = data.getEnergyInfo();
		DialDailyGoalInfo info = new DialDailyGoalInfo();
		info.setCount(energyInfo.getCount());
		info.setLastDay(energyInfo.getLastDay());
		List<TwoInt> statusList = energyInfo.getRewardStatusList();
		if (statusList != null && !statusList.isEmpty()) {
			for (TwoInt t : statusList) {
				info.getRewardStatus().put(t.getV1(), t.getV2());
			}
		}
		return info;
	}

	public static void serFortuneDialDayInfo(SerData.Builder serData, DialDailyGoalInfo fortuneInfo) {
		CommonPb.DialDailyGoalInfo.Builder builder = CommonPb.DialDailyGoalInfo.newBuilder();
		builder.setCount(fortuneInfo.getCount());
		builder.setLastDay(fortuneInfo.getLastDay());
		Map<Integer, Integer> status = fortuneInfo.getRewardStatus();
		for (Map.Entry<Integer, Integer> e : status.entrySet()) {
			builder.addRewardStatus(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}
		serData.setFortuneInfo(builder.build());
	}

	public static DialDailyGoalInfo dserFortuneDialDayInfo(SerData data) {
		CommonPb.DialDailyGoalInfo fortuneInfo = data.getFortuneInfo();
		DialDailyGoalInfo info = new DialDailyGoalInfo();
		info.setCount(fortuneInfo.getCount());
		info.setLastDay(fortuneInfo.getLastDay());
		List<TwoInt> statusList = fortuneInfo.getRewardStatusList();
		if (statusList != null && !statusList.isEmpty()) {
			for (TwoInt t : statusList) {
				info.getRewardStatus().put(t.getV1(), t.getV2());
			}
		}
		return info;
	}

	public static void serEquipDialDayInfo(SerData.Builder serData, DialDailyGoalInfo equipInfo) {
		CommonPb.DialDailyGoalInfo.Builder builder = CommonPb.DialDailyGoalInfo.newBuilder();
		builder.setCount(equipInfo.getCount());
		builder.setLastDay(equipInfo.getLastDay());
		Map<Integer, Integer> status = equipInfo.getRewardStatus();
		for (Map.Entry<Integer, Integer> e : status.entrySet()) {
			builder.addRewardStatus(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}
		serData.setEquipInfo(builder.build());
	}

	public static DialDailyGoalInfo dserEquipDialDayInfo(SerData data) {
		CommonPb.DialDailyGoalInfo equipInfo = data.getEquipInfo();
		DialDailyGoalInfo info = new DialDailyGoalInfo();
		info.setCount(equipInfo.getCount());
		info.setLastDay(equipInfo.getLastDay());
		List<TwoInt> statusList = equipInfo.getRewardStatusList();
		if (statusList != null && !statusList.isEmpty()) {
			for (TwoInt t : statusList) {
				info.getRewardStatus().put(t.getV1(), t.getV2());
			}
		}
		return info;
	}

	public static void serTicDialDayInfo(SerData.Builder serData, DialDailyGoalInfo ticDialDayInfo) {
		CommonPb.DialDailyGoalInfo.Builder builder = CommonPb.DialDailyGoalInfo.newBuilder();
		builder.setCount(ticDialDayInfo.getCount());
		builder.setLastDay(ticDialDayInfo.getLastDay());
		Map<Integer, Integer> status = ticDialDayInfo.getRewardStatus();
		for (Map.Entry<Integer, Integer> e : status.entrySet()) {
			builder.addRewardStatus(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
		}
		serData.setTicInfo(builder.build());
	}

	public static DialDailyGoalInfo dserTicDialDayInfo(SerData data) {
		CommonPb.DialDailyGoalInfo ticInfo = data.getTicInfo();
		DialDailyGoalInfo info = new DialDailyGoalInfo();
		if (ticInfo != null) {
			info.setCount(ticInfo.getCount());
			info.setLastDay(ticInfo.getLastDay());
			List<TwoInt> statusList = ticInfo.getRewardStatusList();
			if (statusList != null && !statusList.isEmpty()) {
				for (TwoInt t : statusList) {
					info.getRewardStatus().put(t.getV1(), t.getV2());
				}
			}
		}
		return info;
	}

}
