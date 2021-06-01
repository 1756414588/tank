package com.hundredcent.game.aop.transformer;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;

import javassist.CannotCompileException;
import javassist.CtClass;
import javassist.CtField;
import javassist.CtMethod;

import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.annotation.SaveOptimize;
import com.hundredcent.game.util.AgentLogUtil;

/**
 * 数据持久化相关的Transformer
 *
 * @author Tandonghai
 * @date 2018-01-09 11:13
 */
public abstract class AbstractPersisitenceTransformer extends AbstractClassFileTransformer {

    private static Map<SaveLevel, String> insertMothedMap = new ConcurrentHashMap<>();

    private static Set<String> objectidNameSet = new HashSet<>();

    /** 注册每种保存级别对应的方法 */
    public static void registInsertMethod(SaveLevel level, String method) {
        AgentLogUtil.saveInfo(level.toString() + " =  " + method);
        insertMothedMap.put(level, method);
    }

    /** 代理类传入的唯一标识名 */
    public static void registObjectidName(String filedName) {
        objectidNameSet.add(filedName);
    }

    /**
     * 匹配setter方法，当前只对setter方法进行处理
     */
    private Pattern setterMethodPattern = Pattern.compile("^set[A-Z]+");

    protected List<AbstractPrepareTransformer> prepareTransformerList = new ArrayList<>();

    public AbstractPersisitenceTransformer() {
        regPrepareTransformer();
    }

    private void regPrepareTransformer() {
        prepareTransformerList.add(new PlayerPrepareTransformer());
    }

    @Override
    protected boolean doPrepareTransformerWork(CtClass cc) {
        boolean wasChanged = false;
        for (AbstractPrepareTransformer prepareTransformer : prepareTransformerList) {
            if (prepareTransformer.doPrepareTransformer(cc)) {
                wasChanged = true;
            }
        }
        return wasChanged;
    }

    @Override
    protected boolean doTransform(CtClass cc) {
        boolean wasChanged = false;
        String roleIdFieldName = getRoleIdName(cc);
        SaveLevel classSaveLevel = getClassSaveLevel(cc);
        List<CtField> saveOptimizeFileds = getSaveOptimizeFileds(cc);
        for (CtMethod method : cc.getDeclaredMethods()) {
            String insertMethod = null;
            SaveLevel methodSaveLevel = getMethodSaveLevel(method);
            boolean isSaveOptimizeMethod = isSaveOptimize(methodSaveLevel);

            if (isSetterMethod(method.getName())) {
                insertMethod = splicePlayerSetterInsertMethod(classSaveLevel, methodSaveLevel, saveOptimizeFileds, method.getName(), roleIdFieldName);
            } else if (isSaveOptimizeMethod) {
                insertMethod = splicePlayerInsertMethodName(roleIdFieldName, method.getName(), methodSaveLevel);
            }

            if (null != insertMethod) {
                try {
                    AgentLogUtil.saveInfo(String.format("方法注入, method:%s.%s(), insertMethod:%s", cc.getName(), method.getName(), insertMethod));
                    method.insertAfter(insertMethod);
                    wasChanged = true;
                } catch (CannotCompileException e) {
                    AgentLogUtil.error(String.format("insertMethod出错, method:%s.%s(), insertMethod:%s", cc.getName(), method.getName(), insertMethod), e);
                }
            }
        }
        return wasChanged;
    }

    /**
     * 拼接Player相关类中setter方法，需要插入的优化方法字符串
     *
     * @param classSaveLevel
     * @param methodSaveLevel
     * @param saveOptimizeFileds
     * @param methodName
     * @param roleIdFieldName
     * @return
     */
    protected String splicePlayerSetterInsertMethod(SaveLevel classSaveLevel, SaveLevel methodSaveLevel, List<CtField> saveOptimizeFileds, String methodName, String roleIdFieldName) {
        if (null != roleIdFieldName) {
            SaveLevel level = SaveLevel.CYCLE;
            // 如果setter方法上添加了注解，以方法上的为有效注解
            if (!methodSaveLevel.equals(SaveLevel.CYCLE)) {
                level = methodSaveLevel;
            } else {
                SaveLevel filedSaveLevel = SaveLevel.CYCLE;
                String filedName = parseSetterParamName(methodName);
                for (CtField filed : saveOptimizeFileds) {
                    if (filed.getName().equals(filedName)) {
                        filedSaveLevel = getFiledSaveLevel(filed);
                        break;
                    }
                }
                // 如果方法时没有添加注解，以变量上的为有效注解
                if (!filedSaveLevel.equals(SaveLevel.CYCLE)) {
                    level = filedSaveLevel;
                } else {
                    // 如果变量上也没有添加注解，以类上添加的注解为有效注解
                    level = classSaveLevel;
                }
            }
            // 只处理需要优化的保存等级
            if (isSaveOptimize(level)) {
                return splicePlayerInsertMethodName(roleIdFieldName, methodName, level);
            }
        }
        return null;
    }

    /**
     * 拼接Player相关优化最后需要嵌入的方法字符串
     *
     * @param roleIdFieldName
     * @param level
     * @return
     */
    protected String splicePlayerInsertMethodName(String roleIdFieldName, String methodName, SaveLevel level) {
        if (null != roleIdFieldName) {
            if (insertMothedMap.containsKey(level)) {
                return String.format(insertMothedMap.get(level), roleIdFieldName, methodName);
            }
        }
        return null;
    }

    /**
     * 该保存等级是否需要执行保存优化
     *
     * @param level
     * @return
     */
    protected boolean isSaveOptimize(SaveLevel level) {
        return insertMothedMap.containsKey(level);
    }

    /**
     * 获取全局变量上标注的保存优化等级
     *
     * @param field
     * @return
     */
    protected SaveLevel getFiledSaveLevel(CtField field) {
        try {
            SaveOptimize saveOptimize = (SaveOptimize) field.getAnnotation(SaveOptimize.class);
            if (saveOptimize != null) {
                return saveOptimize.level();
            }
        } catch (ClassNotFoundException e) {
            AgentLogUtil.error(String.format("获取变量的保存等级出错, field:%s", field.getName()), e);
        }
        return SaveLevel.CYCLE;
    }

    /**
     * 获取方法上标注的保存优化等级
     *
     * @param method
     * @return
     */
    protected SaveLevel getMethodSaveLevel(CtMethod method) {
        try {
            SaveOptimize saveOptimize = (SaveOptimize) method.getAnnotation(SaveOptimize.class);
            if (saveOptimize != null) {
                return saveOptimize.level();
            }
        } catch (ClassNotFoundException e) {
            AgentLogUtil.error(String.format("获取方法的保存等级出错, method:%s", method.getName()), e);
        }
        return SaveLevel.CYCLE;
    }

    /**
     * 获取类上标注的保存优化等级
     *
     * @param cc
     * @return
     */
    protected SaveLevel getClassSaveLevel(CtClass cc) {
        try {
            SaveOptimize saveOptimize = (SaveOptimize) cc.getAnnotation(SaveOptimize.class);
            if (saveOptimize != null) {
                return saveOptimize.level();
            }
        } catch (ClassNotFoundException e) {
            AgentLogUtil.error(String.format("获取类的保存等级出错, class:%s", cc.getName()), e);
        }
        return SaveLevel.CYCLE;
    }

    /**
     * 获取类中所有添加了保存优化注解的变量
     *
     * @param cc
     * @return
     */
    protected List<CtField> getSaveOptimizeFileds(CtClass cc) {
        List<CtField> list = new ArrayList<>();
        for (CtField ctField : cc.getDeclaredFields()) {
            try {
                if (ctField.getAnnotation(SaveOptimize.class) != null) {
                    list.add(ctField);
                }
            } catch (ClassNotFoundException e) {
                AgentLogUtil.error(String.format("获取类中所有添加了保存优化注解的变量出错, class:%s", cc.getName()), e);
            }
        }
        return list;
    }

    @Override
    protected String[] requiredAnnotations() {
        return new String[] { getSaveOptimizeAnnotationName() };
    }

    /**
     * 返回保存优化基础注解类名称
     *
     * @return
     */
    protected String getSaveOptimizeAnnotationName() {
        return SaveOptimize.class.getName();
    }

    /**
     * 由于历史原因，角色id在不同项目不同类中的名称可能不一致，该方法用于判断类中是否包含角色id属性，有则返回属性名称，否则返回null
     *
     * @param cc
     * @return
     */
    protected String getRoleIdName(CtClass cc) {
        String filedName;
        for (CtField ctField : cc.getDeclaredFields()) {
            filedName = ctField.getName();
            if (objectidNameSet.contains(filedName)) {
                return filedName;
            }
        }
        return null;
    }

    /**
     * 从setter方法中获取参数名称
     *
     * @param setterMethod
     * @return
     */
    protected String parseSetterParamName(String setterMethod) {
        if (setterMethod != null && setterMethod.length() > 0 && isSetterMethod(setterMethod)) {
            return fisrtLowerCase(setterMethod.substring(3));
        }
        return "";
    }

    protected String fisrtLowerCase(String str) {
        return (new StringBuilder()).append(Character.toLowerCase(str.charAt(0))).append(str.substring(1)).toString();
    }

    protected boolean isSetterMethod(String methodName) {
        return null != methodName && setterMethodPattern.matcher(methodName).find();
    }
}
