package merge;

import com.game.dao.impl.p.*;
import com.mchange.v2.c3p0.ComboPooledDataSource;
import com.mysql.jdbc.jdbc2.optional.MysqlDataSource;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

import java.util.ArrayList;
import java.util.List;
/**
* @Author :GuiJie Liu
* @date :Create in 2019/5/28 10:11
* @Description :java类作用描述
*/
public class MyBatisM {


    private SqlSessionFactory sqlSessionFactory;
    private MysqlDataSource mysqlDataSource;

    public SqlSessionFactory getSqlSessionFactory() {
        return this.sqlSessionFactory;
    }

    public MysqlDataSource getDataSource() {
        return this.mysqlDataSource;
    }

    public MyBatisM(String url, String user, String pwd) throws Exception {

        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();

        if (MergeMain.isDebug) {
            ComboPooledDataSource dataSoucePool = new ComboPooledDataSource();
            dataSoucePool.setDriverClass("com.mysql.jdbc.Driver");
            dataSoucePool.setJdbcUrl(url);
            dataSoucePool.setUser(user);
            dataSoucePool.setPassword(pwd);
            dataSoucePool.setInitialPoolSize(100);
            dataSoucePool.setMinPoolSize(100);
            dataSoucePool.setMinPoolSize(500);
            dataSoucePool.setMaxIdleTime(14400);
            dataSoucePool.setAcquireIncrement(5);
            dataSoucePool.setAcquireRetryAttempts(30);
            dataSoucePool.setAcquireRetryDelay(500);
            dataSoucePool.setNumHelperThreads(5);
            sqlSessionFactoryBean.setDataSource(dataSoucePool);

        } else {
            this.mysqlDataSource = new MysqlDataSource();
            this.mysqlDataSource.setUrl(url);
            this.mysqlDataSource.setUser(user);
            this.mysqlDataSource.setPassword(pwd);
            this.mysqlDataSource.setTcpKeepAlive(true);
            this.mysqlDataSource.setAutoReconnect(true);
            sqlSessionFactoryBean.setDataSource(this.mysqlDataSource);
        }

        List<Resource> rs = new ArrayList<>();
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/AccountDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/ActivityDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/ArenaDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/BossDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/BuildingDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/DataNewDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/ExtremeDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/GlobalDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/LordDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/LordRelationDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/PartyDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/PayDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/ResourceDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/ServerLogDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/SmallIdDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/StaticParamDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/TipGuyDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/UClientMessageDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/AdvertisementDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/p/MailDao.xml"));
        rs.add(new ClassPathResource("com/game/dao/sqlMap/s/StaticDataDao.xml"));
        sqlSessionFactoryBean.setMapperLocations((Resource[]) rs.toArray(new Resource[rs.size()]));
        sqlSessionFactoryBean.setTypeAliasesPackage("com.game.domain");
        this.sqlSessionFactory = sqlSessionFactoryBean.getObject();
        //初始化DAO信息
        initDao();
    }

    private LordDao lordDao;
    private AccountDao accountDao;
    private BuildingDao buildingDao;
    private ResourceDao resourceDao;
    private TipGuyDao tipGuyDao;
    private DataNewDao dataNewDao;
    private PartyDao partyDao;
    private PayDao payDao;
    private AdvertisementDao adDao;
    private SmallIdDao smallIdDao;
    private ArenaDao arenaDao;
    private MailDao mailDao;
    private StaticParamDao staticParamDao;
    private GlobalDao globalDao;


    /**
     * 初始化合服的DAO
     */
    private void initDao() {
        lordDao = new LordDao();
        lordDao.setSqlSessionFactory(sqlSessionFactory);

        accountDao = new AccountDao();
        accountDao.setSqlSessionFactory(sqlSessionFactory);

        buildingDao = new BuildingDao();
        buildingDao.setSqlSessionFactory(sqlSessionFactory);

        resourceDao = new ResourceDao();
        resourceDao.setSqlSessionFactory(sqlSessionFactory);

        tipGuyDao = new TipGuyDao();
        tipGuyDao.setSqlSessionFactory(sqlSessionFactory);

        dataNewDao = new DataNewDao();
        dataNewDao.setSqlSessionFactory(sqlSessionFactory);

        partyDao = new PartyDao();
        partyDao.setSqlSessionFactory(sqlSessionFactory);

        payDao = new PayDao();
        payDao.setSqlSessionFactory(sqlSessionFactory);

        adDao = new AdvertisementDao();
        adDao.setSqlSessionFactory(sqlSessionFactory);

        smallIdDao = new SmallIdDao();
        smallIdDao.setSqlSessionFactory(sqlSessionFactory);

        arenaDao = new ArenaDao();
        arenaDao.setSqlSessionFactory(sqlSessionFactory);

        mailDao = new MailDao();
        mailDao.setSqlSessionFactory(sqlSessionFactory);

        staticParamDao = new StaticParamDao();
        staticParamDao.setSqlSessionFactory(sqlSessionFactory);

        globalDao = new GlobalDao();
        globalDao.setSqlSessionFactory(sqlSessionFactory);
    }

    public LordDao getLordDao() {
        return lordDao;
    }

    public AccountDao getAccountDao() {
        return accountDao;
    }

    public BuildingDao getBuildingDao() {
        return buildingDao;
    }

    public ResourceDao getResourceDao() {
        return resourceDao;
    }

    public TipGuyDao getTipGuyDao() {
        return tipGuyDao;
    }

    public DataNewDao getDataNewDao() {
        return dataNewDao;
    }

    public PartyDao getPartyDao() {
        return partyDao;
    }

    public PayDao getPayDao() {
        return payDao;
    }

    public AdvertisementDao getAdDao() {
        return adDao;
    }

    public SmallIdDao getSmallIdDao() {
        return smallIdDao;
    }

    public ArenaDao getArenaDao() {
        return arenaDao;
    }

    public MailDao getMailDao() {
        return mailDao;
    }

    public StaticParamDao getStaticParamDao() {
        return staticParamDao;
    }

    public GlobalDao getGlobalDao() {
        return globalDao;
    }
}
