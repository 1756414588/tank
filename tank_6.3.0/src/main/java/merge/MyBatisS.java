package merge;

import com.game.dao.impl.s.StaticDataDao;
import com.mysql.jdbc.jdbc2.optional.MysqlDataSource;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

import java.util.ArrayList;
import java.util.List;

public class MyBatisS {
    private SqlSessionFactory sqlSessionFactory;
    private MysqlDataSource mysqlDataSource;

    public SqlSessionFactory getSqlSessionFactory() {
        return this.sqlSessionFactory;
    }

    public MysqlDataSource getDataSource() {
        return this.mysqlDataSource;
    }

    public MyBatisS(String url, String user, String pwd) throws Exception {
        this.mysqlDataSource = new MysqlDataSource();
        this.mysqlDataSource.setUrl(url);
        this.mysqlDataSource.setUser(user);
        this.mysqlDataSource.setPassword(pwd);
        this.mysqlDataSource.setTcpKeepAlive(true);
        this.mysqlDataSource.setAutoReconnect(true);

//        ComboPooledDataSource dataSoucePool = new ComboPooledDataSource();
//        dataSoucePool.setDriverClass("com.mysql.jdbc.Driver");
//        dataSoucePool.setJdbcUrl(url);
//        dataSoucePool.setUser(user);
//        dataSoucePool.setPassword(pwd);
//        dataSoucePool.setInitialPoolSize(100);
//        dataSoucePool.setMinPoolSize(100);
//        dataSoucePool.setMinPoolSize(500);
//        dataSoucePool.setMaxIdleTime(14400);
//        dataSoucePool.setAcquireIncrement(5);
//        dataSoucePool.setAcquireRetryAttempts(30);
//        dataSoucePool.setAcquireRetryDelay(500);
//        dataSoucePool.setNumHelperThreads(5);


        List<Resource> rs = new ArrayList<>();

        rs.add(new ClassPathResource("com/game/dao/sqlMap/s/StaticDataDao.xml"));

        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(this.mysqlDataSource);
        sqlSessionFactoryBean.setMapperLocations((Resource[]) rs.toArray(new Resource[rs.size()]));

		sqlSessionFactoryBean.setTypeAliasesPackage("com.game.domain.s");
        this.sqlSessionFactory = sqlSessionFactoryBean.getObject();
        //初始化DAO信息
        initDao();
//        LogUtil.error(String.format("url :%s, init DAO finish, smalldao :%s", url, getStaticDataDao()));
    }

    private StaticDataDao staticDataDao;


    /**
     * 初始化合服的DAO
     */
    private void initDao() {
        staticDataDao = new StaticDataDao();
        staticDataDao.setSqlSessionFactory(sqlSessionFactory);
    }

    public StaticDataDao getStaticDataDao() {
        return staticDataDao;
    }
}
