/**
 *
 */
package com.hotfix;

import com.game.server.GameServer;
import com.game.util.LogUtil;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.context.ConfigurableApplicationContext;

import java.util.Arrays;

/**
 * 基于SPRING对象的热更新
 *
 * @author zhangdh
 */
public class HotfixInSpring {

    /**
     * redefineBean("shopHandler","com.dilonet.game.handler.ShopHandler1");
     * 重新定义Bean
     *
     * @param beanName
     * @param newClassName
     */
    public static void redefineBean(String beanName, String newClassName) {
        ConfigurableApplicationContext configurableApplicationContext = (ConfigurableApplicationContext) GameServer.ac;
        DefaultListableBeanFactory beanFactory = (DefaultListableBeanFactory) configurableApplicationContext.getBeanFactory();
        BeanDefinition def = beanFactory.getBeanDefinition(beanName);
        String[] dependents = beanFactory.getDependentBeans(beanName);//依赖此beanName的Bean列表
        def.setBeanClassName(newClassName);
        beanFactory.registerBeanDefinition(beanName, def);
        LogUtil.common("dependents : " + Arrays.toString(dependents));
        resetDependents(dependents, beanFactory);
    }

    /**
     * 递归更新所有对象引用
     *
     * @param dependents
     * @param beanFactory
     */
    private static void resetDependents(String[] dependents, DefaultListableBeanFactory beanFactory) {
        if (dependents == null || dependents.length == 0) return;
        for (String dependentName : dependents) {
            BeanDefinition db = beanFactory.getBeanDefinition(dependentName);
            beanFactory.registerBeanDefinition(dependentName, db);
            String[] deepDependents = beanFactory.getDependentBeans(dependentName);//更深层次的引用关系
            resetDependents(deepDependents, beanFactory);
        }
    }

    public static void redefineHandler(String handlerName, String newClassName) {
        Object obj = GameServer.ac.getBean(handlerName);
        if (obj == null) throw new NullPointerException("spring not found handler : " + handlerName);
        LogUtil.common(String.format("start hotfix handler :%s, class name :%s ......", handlerName, obj.getClass().getName()));
        redefineBean(handlerName, newClassName);
        LogUtil.common(String.format("hotfix class :%s  ----> class :%s", handlerName, newClassName));
    }

    public static void redefineJob(String jobName, String newClassName) {
        redefineBean(jobName, newClassName);
    }

    public static void redefenObserver(String observerName, String newClassName) {
        redefineBean(observerName, newClassName);
    }

    public static void redefineDict(String dictName, String newClassName) {
        redefineBean(dictName, newClassName);
    }

}
