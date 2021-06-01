package merge;

import java.util.HashSet;
import java.util.Set;

/**
 * 合服的服务器信息
 */
public class MServer implements Comparable<MServer>{
    //***********json解析的数据***************
	private int serverId;

	private String dbUrl;
	
	private String user;
	
	private String pwd;
	
	private String nickSuffix;


	//**********查询或者后来生成的数据**************
	private String serverName;
    public MergeGame mergeGame;
    public MyBatisM myBatisM;
    public Boolean hasMerge;//临时变量  之前是否合服过

    //slave服中所有有效的玩家ID列表，此处不用同步set是因为读线程开启时数据已经完全写好了
    public Set<Long> totalIds = new HashSet<>();
	/**
	 * 需要添加到小号表中的lordId
	 */
	private Set<Long> needAddSmallIdLords = new HashSet<>();
	
	public int getServerId() {
		return serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	public String getDbUrl() {
		return dbUrl;
	}

	public void setDbUrl(String dbUrl) {
		this.dbUrl = dbUrl;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public String getPwd() {
		return pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	public String getNickSuffix() {
		return nickSuffix;
	}

	public void setNickSuffix(String nickSuffix) {
		this.nickSuffix = nickSuffix;
	}

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

	public Set<Long> getNeedAddSmallIdLords() {
		return needAddSmallIdLords;
	}

	public void setNeedAddSmallIdLords(Set<Long> needAddSmallIdLords) {
		this.needAddSmallIdLords = needAddSmallIdLords;
	}

	@Override
	public int compareTo(MServer o) {
		return this.getServerId() - o.getServerId();
	}
}
