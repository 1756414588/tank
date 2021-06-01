package com.game.service.teaminstance;

import com.game.common.ServerSetting;
import com.game.constant.FormType;
import com.game.constant.SkinType;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.domain.MedalBouns;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.grpc.proto.team.TeamHandlerGrpc;
import com.game.manager.PartyDataManager;
import com.game.server.GameServer;
import com.game.server.rpc.pool.GRpcConnection;
import com.game.server.rpc.pool.GRpcPoolManager;
import com.game.service.FightService;
import com.game.util.*;
import com.google.common.util.concurrent.ListenableFuture;

import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/22 16:42
 * @description：远程方法
 */
public class TeamRpcService {

    public static final long timeOut = 300L;

    /**
     * 同步玩家信息到跨服
     * <p>
     * flag : true 只有在寻找队伍加入队伍成功后才传属性信息.
     * type : 1.同步组队  2.同步跨服军矿
     */
    public static void synPlayer(Player player, PartyDataManager partyDataManager, FightService fightService, boolean flag, int type) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return;
            }
            CrossTeamProto.RpcSynPlayerRequest.Builder builder = CrossTeamProto.RpcSynPlayerRequest.newBuilder();
            builder.setServerId(GameServer.ac.getBean(ServerSetting.class).getServerID());
            String openTime = GameServer.ac.getBean(ServerSetting.class).getOpenTime();
            Date openDate = DateHelper.parseDate(openTime);
            int dayiy = DateHelper.dayiy(openDate, new Date());
            builder.setOpenTime(dayiy);
            builder.setRoleId(player.lord.getLordId());
            builder.setNick(player.lord.getNick());
            //builder.setFight(player.lord.getFight());
            builder.setLevel(player.lord.getLevel());
            builder.setPortrait(player.lord.getPortrait());
            builder.setFight(player.lord.getFight());
            if (type == 1) {
                Form form1 = player.forms.get(FormType.TEAM);
                if (form1 != null) {
                    Form form = new Form(form1);
                    builder.setFight(fightService.calcFormFight(player, form));
                    builder.setForm(CrossPbHelper.createFormPb(form));
                }
            }
            Member member = partyDataManager.getMemberById(player.lord.getLordId());
            if (member != null) {
                builder.setPartyId(member.getPartyId());

                PartyData party = partyDataManager.getParty(member.getPartyId());
                if (party != null) {
                    builder.setPartyName(party.getPartyName());
                }
            }
            builder.setVip(player.lord.getVip());
            builder.setHonor(player.lord.getHonour());
            builder.setPros(player.lord.getPros());
            builder.setMaxPros(player.lord.getProsMax());
            builder.setCrossMineScore(player.getCrossMineScore());
            // effect
            Iterator<Effect> itEffect = player.effects.values().iterator();
            while (itEffect.hasNext()) {
                builder.addEffect(CrossPbHelper.createEffectPb(itEffect.next()));
            }

            builder.setType(type);
            //作战实验室
            if (!player.labInfo.getGraduateInfo().isEmpty()) {
                List<CrossTeamProto.GraduateInfoPb> list = CrossPbHelper.createGraduateInfoPb(player.labInfo.getGraduateInfo());
                if (!list.isEmpty()) {
                    builder.addAllGraduateInfo(list);
                }
            }
            //玩家军团科技列表
            if (partyDataManager.getScience(player) != null && !partyDataManager.getScience(player).isEmpty()) {
                Iterator<PartyScience> psIt = partyDataManager.getScience(player).values().iterator();
                while (psIt.hasNext()) {
                    builder.addPartyScience(CrossPbHelper.createPartySciencePb(psIt.next()));
                }
            }
            if (flag) {
                builder.setStaffingId(player.lord.getStaffing());
                builder.setMilitaryRank(player.lord.getMilitaryRank());
                // 装备
                for (int i = 0; i < 7; i++) {
                    Map<Integer, Equip> equipMap = player.equips.get(i);
                    Iterator<Equip> itEquip = equipMap.values().iterator();
                    while (itEquip.hasNext()) {
                        builder.addEquip(CrossPbHelper.getCrossEquipPb(itEquip.next()));
                    }
                }
                // 科技
                Iterator<Science> itScience = player.sciences.values().iterator();
                while (itScience.hasNext()) {
                    builder.addScience(CrossPbHelper.getCrossSciencePb(itScience.next()));
                }
                // 配件
                for (int i = 0; i < 5; i++) {
                    Map<Integer, Part> map = player.parts.get(i);
                    Iterator<Part> itPart = map.values().iterator();
                    while (itPart.hasNext()) {
                        builder.addPart(CrossPbHelper.getCrossPartPb(itPart.next()));
                    }
                }
                //技能
                if (!player.skills.isEmpty()) {
                    for (Map.Entry<Integer, Integer> entry : player.skills.entrySet()) {
                        builder.addSkill(CrossPbHelper.getSkillPb(entry.getKey(), entry.getValue()));
                    }
                }
                //
                // 能晶
                for (int pos = 1; pos <= 6; pos++) {
                    Map<Integer, EnergyStoneInlay> stoneMap = player.energyInlay.get(pos);
                    if (!CheckNull.isEmpty(stoneMap)) {
                        for (EnergyStoneInlay inlay : stoneMap.values()) {
                            builder.addInlay(CrossPbHelper.createEnergyStoneInlayPb(inlay));
                        }
                    }
                }
                Iterator<MilitaryScience> itms = player.militarySciences.values().iterator();
                while (itms.hasNext()) {
                    builder.addMilitaryScience(CrossPbHelper.createMilitaryScienecePb(itms.next()));
                }
                // 军工科技
                Collection<Map<Integer, MilitaryScienceGrid>> c = player.militaryScienceGrids.values();
                for (Map<Integer, MilitaryScienceGrid> hashMap : c) {
                    Iterator<MilitaryScienceGrid> itmg = hashMap.values().iterator();
                    while (itmg.hasNext()) {
                        builder.addMilitaryScienceGrid(CrossPbHelper.createMilitaryScieneceGridPb(itmg.next()));
                    }
                }
                // 勋章
                for (Map<Integer, Medal> map : player.medals.values()) {
                    Iterator<Medal> itmedls = map.values().iterator();
                    while (itmedls.hasNext()) {
                        builder.addMedal(CrossPbHelper.createMedalPb(itmedls.next()));
                    }
                }
                // 勋章展厅
                for (Map<Integer, MedalBouns> map : player.medalBounss.values()) {
                    Iterator<MedalBouns> itmedls = map.values().iterator();
                    while (itmedls.hasNext()) {
                        builder.addMedalBouns(CrossPbHelper.createMedalBounsPb(itmedls.next()));
                    }
                }
                //觉醒将领
                for (AwakenHero hero : player.awakenHeros.values()) {
                    builder.addAwakenHero(CrossPbHelper.createAwakenHeroPb(hero));
                }
                //军备列表
                if (!player.leqInfo.getPutonLordEquips().isEmpty()) {
                    for (Map.Entry<Integer, LordEquip> entry : player.leqInfo.getPutonLordEquips().entrySet()) {
                        builder.addLeq(CrossPbHelper.createLordEquip(entry.getValue()));
                    }
                }
                if (!player.secretWeaponMap.isEmpty()) {
                    for (Map.Entry<Integer, SecretWeapon> entry : player.secretWeaponMap.entrySet()) {
                        builder.addSecretWeapon(CrossPbHelper.createSecretWeapon(entry.getValue()));
                    }
                }
                //攻击特效
                if (!player.atkEffects.isEmpty()) {
                    for (Map.Entry<Integer, AttackEffect> entry : player.atkEffects.entrySet()) {
                        builder.addAtkEft(CrossPbHelper.createAttackEffectPb(entry.getValue()));
                    }
                }
                builder.setEnergyCore(CrossPbHelper.createThreeIntPb(player.energyCore.getLevel(), player.energyCore.getSection(), player.energyCore.getState()));
            }
            long t = System.currentTimeMillis();
            team.synPlayer(builder.build());
            LogUtil.crossInfo("同步玩家信息到跨服 耗时 roleId={}, {} ms", player.roleId, (System.currentTimeMillis() - t));
            //return rpcFindTeamResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 创建队伍
     *
     * @param roleId
     * @param teamType
     * @return
     */
    public static CrossTeamProto.RpcCreateTeamResponse createTeam(long roleId, int teamType, long fight) {

        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.RpcCreateTeamRequest.Builder builder = CrossTeamProto.RpcCreateTeamRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setTeamType(teamType);
            builder.setFight(fight);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCreateTeamResponse> rpcCreateTeamResponseListenableFuture = team.createTeam(builder.build());
            CrossTeamProto.RpcCreateTeamResponse rpcCreateTeamResponse = rpcCreateTeamResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 创建队伍 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcCreateTeamResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 解散队伍
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse disMissTeam(long roleId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.RpcDisMissTeamRequest.Builder builder = CrossTeamProto.RpcDisMissTeamRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcDissTeamResponseListenableFuture = team.dismissTeam(builder.build());
            CrossTeamProto.RpcCodeTeamResponse rpcDissTeamResponse = rpcDissTeamResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 解散队伍 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcDissTeamResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 寻找队伍
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse findTeam(long roleId, int teamType) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.RpcFindTeamRequest.Builder builder = CrossTeamProto.RpcFindTeamRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setTeamType(teamType);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcFindTeamResponseListenableFuture = team.findTeam(builder.build());
            CrossTeamProto.RpcCodeTeamResponse rpcFindTeamResponse = rpcFindTeamResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("寻找队伍 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcFindTeamResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 离开队伍
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse leave(long roleId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.RpcLeaveTeamRequest.Builder builder = CrossTeamProto.RpcLeaveTeamRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcleaveTeamResponseListenableFuture = team.leaveTeam(builder.build());
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = rpcleaveTeamResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("离开队伍 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcCodeTeamResponse;

        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 踢出队伍
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse kickTeam(long roleId, long broleId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.RpcKickTeamRequest.Builder builder = CrossTeamProto.RpcKickTeamRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setBroleId(broleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcleaveTeamResponseListenableFuture = team.kickTeam(builder.build());
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = rpcleaveTeamResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("踢出队伍 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcCodeTeamResponse;

        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 加入队伍
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse joinTeam(long roleId, int teamId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.RpcJoinTeamRequest.Builder builder = CrossTeamProto.RpcJoinTeamRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setTeamId(teamId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcJoinTeamResponseListenableFuture = team.joinTeam(builder.build());
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = rpcJoinTeamResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("加入队伍 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcCodeTeamResponse;

        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 改变队员状态
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse changeMemberStatus(long roleId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.RpcChangeMemberStatusRequest.Builder builder = CrossTeamProto.RpcChangeMemberStatusRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcChangeTeamResponseListenableFuture = team.changeMemberStatus(builder.build());
            CrossTeamProto.RpcCodeTeamResponse rpcFindTeamResponse = rpcChangeTeamResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("改变队员状态 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcFindTeamResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 改变出战顺序
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse changeOrder(long roleId, int one, int two) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossExchangeOrderRequest.Builder builder = CrossTeamProto.CrossExchangeOrderRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setRoleOne(one);
            builder.setRoleTwo(two);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcChangeTeamResponseListenableFuture = team.changeTeamOrder(builder.build());
            CrossTeamProto.RpcCodeTeamResponse rpcFindTeamResponse = rpcChangeTeamResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("改变出战顺序 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcFindTeamResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 聊天
     *
     * @param roleId
     * @return
     */
    @Deprecated
    public static CrossTeamProto.CrossTeamChatResponse teamChat(long roleId, String message, long chatTime) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossTeamChatRequest.Builder builder = CrossTeamProto.CrossTeamChatRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setMessage(message);
            builder.setTime(chatTime);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.CrossTeamChatResponse> rpcTeamChatResponseListenableFuture = team.teamChat(builder.build());
            CrossTeamProto.CrossTeamChatResponse rpcCrossTeamChatResponse = rpcTeamChatResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("聊天 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return rpcCrossTeamChatResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }


    /**
     * 查看阵型
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.CrossLookFormResponse lookForm(long roleId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossLookFormRequest.Builder builder = CrossTeamProto.CrossLookFormRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.CrossLookFormResponse> rpclookResponseListenableFuture = team.lookForm(builder.build());
            CrossTeamProto.CrossLookFormResponse crossLookFormResponse = rpclookResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("查看阵型 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return crossLookFormResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }


    /**
     * 世界消息
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse teamInvite(long roleId, int stageId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossInviteRequest.Builder builder = CrossTeamProto.CrossInviteRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setStageId(stageId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcResponseListenableFuture = team.teamInvite(builder.build());
            CrossTeamProto.RpcCodeTeamResponse crossResponse = rpcResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("世界消息 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return crossResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }


    /**
     * 战斗
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse fight(long roleId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossTeamFightRequest.Builder builder = CrossTeamProto.CrossTeamFightRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcResponseListenableFuture = team.fight(builder.build());
            CrossTeamProto.RpcCodeTeamResponse crossResponse = rpcResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("战斗 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return crossResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 设置阵型
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse synForm(long roleId, Form form, long fight) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossSynFormRequest.Builder builder = CrossTeamProto.CrossSynFormRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setFight(fight);
            builder.setForm(CrossPbHelper.createFormPb(form));
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcResponseListenableFuture = team.synForm(builder.build());
            CrossTeamProto.RpcCodeTeamResponse crossResponse = rpcResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("设置阵型 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return crossResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 玩家退出
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse logOut(long roleId) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossLogOutRequest.Builder builder = CrossTeamProto.CrossLogOutRequest.newBuilder();
            builder.setRoleId(roleId);
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcResponseListenableFuture = team.logOut(builder.build());
            CrossTeamProto.RpcCodeTeamResponse crossResponse = rpcResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("玩家退出 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return crossResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 组队跨服世界聊天
     *
     * @param roleId
     * @return
     */
    public static CrossTeamProto.RpcCodeTeamResponse chat(long roleId, String content, Player player) {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossWorldChatRequest.Builder builder = CrossTeamProto.CrossWorldChatRequest.newBuilder();
            builder.setRoleId(roleId);
            builder.setContent(content);
            builder.setTime(TimeHelper.getCurrentSecond());
            builder.setNickName(player.lord.getNick());
            builder.setPort(player.lord.getPortrait());
            builder.setBubble(player.getCurrentSkin(SkinType.BUBBLE));
            if (player.account.getIsGm() > 0) {
                builder.setIsGm(true);
            }
            builder.setStaffing(player.lord.getStaffing());
            //军衔
            if (GameServer.ac.getBean(StaticFunctionPlanDataMgr.class).isMilitaryRankOpen()) {
                builder.setMilitary(player.lord.getMilitaryRank());
            }
            builder.setVip(player.lord.getVip());
            builder.setLv(player.lord.getLevel());
            builder.setServerName(GameServer.ac.getBean(ServerSetting.class).getServerName());
            builder.setFight(player.lord.getFight());
            PartyDataManager bean = GameServer.ac.getBean(PartyDataManager.class);
            Member member = bean.getMemberById(player.roleId);
            if (member != null && member.getPartyId() > 0) {
                PartyData partyData = bean.getParty(member.getPartyId());
                if (partyData != null) {
                    builder.setPartyName(partyData.getPartyName());
                }
            }
            builder.setServerId(GameServer.ac.getBean(ServerSetting.class).getServerID());
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.RpcCodeTeamResponse> rpcResponseListenableFuture = team.worldChat(builder.build());
            CrossTeamProto.RpcCodeTeamResponse crossResponse = rpcResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo("组队跨服世界聊天 耗时 roleId={}, {} ms", roleId, (System.currentTimeMillis() - t));
            return crossResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    /**
     * 跨服服务器列表
     *
     * @return
     */
    public static CrossTeamProto.CrossServerListResponse queryServerList() {
        try {
            TeamHandlerGrpc.TeamHandlerFutureStub team = getStub();
            if (team == null) {
                return null;
            }
            CrossTeamProto.CrossServerListRequest.Builder builder = CrossTeamProto.CrossServerListRequest.newBuilder();
            long t = System.currentTimeMillis();
            ListenableFuture<CrossTeamProto.CrossServerListResponse> rpcResponseListenableFuture = team.queryServerList(builder.build());
            CrossTeamProto.CrossServerListResponse crossResponse = rpcResponseListenableFuture.get(timeOut, TimeUnit.MILLISECONDS);
            LogUtil.crossInfo(" 跨服服务器列表 耗时  {} ms", (System.currentTimeMillis() - t));
            return crossResponse;
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return null;
    }

    public static TeamHandlerGrpc.TeamHandlerFutureStub getStub() {
        GRpcConnection rpcConnection = null;
        try {
            rpcConnection = GRpcPoolManager.getRpcConnection();
            TeamHandlerGrpc.TeamHandlerFutureStub team = null;
            if (rpcConnection != null) {
                team = TeamHandlerGrpc.newFutureStub(rpcConnection.getChannel());
            }
            return team;
        } catch (Exception e) {
            LogUtil.error(e);
        } finally {
            if (rpcConnection != null) {
                rpcConnection.close();
            }
        }
        return null;
    }

}
