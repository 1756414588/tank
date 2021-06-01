package com.game.service.teaminstance;

import java.util.*;

/**
 * @author : LiFeng
 * @date :
 */
public class TeamManager {

	private static Map<Integer, Team> allTeams = new HashMap<>();

	private static Map<Long, Integer> roleTeam = new HashMap<>();

	private TeamManager() {
		super();
	}

	/**
	 * 根据角色Id获取角色所属队伍
	 * 
	 * @param roleId
	 */
	public static Team getTeamByRoleId(long roleId) {
		if (roleTeam.containsKey(roleId)) {
			return allTeams.get(roleTeam.get(roleId));
		}
		return null;
	}

	/**
	 * 根据队伍Id获取队伍
	 * 
	 * @param teamId
	 */
	public static Team getTeamByTeamId(int teamId) {
		return allTeams.get(teamId);
	}

	/**
	 * 创建队伍时更新队伍列表
	 * 
	 * @param teamId
	 */
	public static void increaseTeam(Team team) {
		allTeams.put(team.getTeamId(), team);
		roleTeam.put(team.getCaptainId(), team.getTeamId());
	}

	/**
	 * 获取所有队伍信息
	 */
	public static List<Team> getAllTeams() {
		return new ArrayList<Team>(allTeams.values());
	}

	/**
	 * 脱离队伍
	 * 
	 * @param roleId
	 */
	public static void leaveTeam(long roleId) {
		roleTeam.remove(roleId);
	}

	/**
	 * 解散队伍
	 * 
	 * @param roleId
	 * @param teamId
	 */
	public static void dismissTeam(Team team) {
		Set<Long> membersInfo = team.getMembersInfo().keySet();
		for (Long memberId : membersInfo) {
			leaveTeam(memberId);
		}
		allTeams.remove(team.getTeamId());		
	}
	
	
	/**
	 * 角色加入队伍
	 * 
	 * @param roleId
	 * @param teamId
	 */
	public static void joinTeam(long roleId, int teamId) {
		roleTeam.put(roleId, teamId);
	}
	

}
