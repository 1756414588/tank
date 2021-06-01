package com.hundredcent.game.aop.transformer;

import javassist.CtClass;

import com.hundredcent.game.util.AgentLogUtil;

/**
 * @author Tandonghai
 * @date 2018-01-09 11:43
 */
public abstract class AbstractClassFileTransformer {

    /**
     * 执行类修改逻辑<br/>
     * 注意：如果本类的子类重写了父类的一些检查方法（如{@link #requiredPackages()}），并返回了不为空的值，该方法被调用时，将会检查传入类是否符合这些检查条件，如果不符合，将什么都不会执行
     *
     * @param cc
     * @return 如果类被修改，返回true
     */
    public boolean transform(CtClass cc) {
        boolean wasChanged = doPrepareTransformerWork(cc);
        if (checkConditions(cc)) {
            if (doTransform(cc)) {
                wasChanged = true;
            }
        }
        return wasChanged;
    }

    /**
     * 执行具体的类修改操作
     *
     * @param cc
     * @return 如果类被修改，返回true
     */
    protected abstract boolean doTransform(CtClass cc);

    /**
     * 检查传入类是否符合条件
     *
     * @param cc
     * @return
     */
    protected boolean checkConditions(CtClass cc) {
        return checkClassPackage(cc) && checkAnnotations(cc);
    }

    /**
     * 一些实现类必要要做的前置准备工作，可以通关实现该方法完成，该方法在{@link #checkConditions(CtClass)}前执行
     *
     * @param cc
     */
    protected boolean doPrepareTransformerWork(CtClass cc) {
        return false;
    }

    /**
     * 检查传入了是否在指定的包体下
     *
     * @param cc
     * @return
     */
    protected boolean checkClassPackage(CtClass cc) {
        String[] packages = requiredPackages();
        if (null == packages || packages.length == 0) {
            return true;
        }

        String pack = cc.getPackageName();
        if (null == pack || pack.length() == 0) {
            return false;
        }

        for (String packageName : packages) {
            if (pack.startsWith(packageName)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 检查传入类是否添加了必须的注解
     *
     * @param cc
     * @returnjh
     */
    protected boolean checkAnnotations(CtClass cc) {
        String[] annotations = requiredAnnotations();
        if (null == annotations || annotations.length == 0) {
            return true;
        }
        for (String annotationClass : annotations) {
            if (!classHaveAssignedAnnotation(cc, annotationClass)) {
                return false;
            }
        }
        return true;
    }

    /**
     * 项目基础包过滤路径，不是该包路径下的类不做transformer检查
     *
     * @return
     */
    public abstract String basePackage();

    /**
     * 返回需要处理的类所在的包路径<br/>
     * 注意：如果该方法返回一个非空的数组，将会检查传入类所在的包是否符合要求，如果不符合，则会被认为是不需要执行{@link #doTransform(CtClass)}的类，将不会对类进行修改
     *
     * @return
     */
    protected String[] requiredPackages() {
        return new String[0];
    }

    /**
     * 返回需要被修改的类必须添加的注解类名称<br/>
     * 注意：如果该方法返回一个非空的数组，将会检查传入类的注解信息，如果该类没有添加这些注解，则会被认为是不需要执行{@link #doTransform(CtClass)}的类，将不会对类进行修改
     *
     * @return
     */
    protected String[] requiredAnnotations() {
        return new String[0];
    }

    /**
     * 传入类是否添加了指定注解
     *
     * @param cc
     * @param annotationClss
     * @return
     */
    protected boolean classHaveAssignedAnnotation(CtClass cc, String annotationClss) {
        if (null == annotationClss || "".equals(annotationClss)) {
            return false;
        }

        try {
            return haveAssignedAnnotation(cc.getAnnotations(), annotationClss);
        } catch (ClassNotFoundException e) {
            AgentLogUtil.error(String.format("检查类是否有指定注解出错, class:%s, annotation:%s", cc.getName(), annotationClss), e);
        }
        return false;
    }

    /**
     * 是否包含指定注解
     *
     * @param annotations
     * @param annotationClss
     * @return
     */
    protected boolean haveAssignedAnnotation(Object[] annotations, String annotationClss) {
        if (null == annotationClss || null == annotations || annotations.length == 0) {
            return false;
        }

        for (Object annotation : annotations) {
            if (annotationClss.equals(parseAnnotationName(annotation.toString()))) {
                return true;
            }
        }
        return false;
    }

    protected String parseAnnotationName(String annotationClassName) {
        if (annotationClassName == null || "".equals(annotationClassName)) {
            return "";
        }

        String name = annotationClassName.trim();
        int index = name.indexOf("@");
        if (index > -1) {
            int endIndex =name.indexOf("(");
            if(endIndex == -1){
                return name.substring(index + 1);
            }
            return name.substring(index + 1, endIndex);
        }
        return name;
    }
}
