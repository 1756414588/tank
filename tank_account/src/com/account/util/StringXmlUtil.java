package com.account.util;


import org.w3c.dom.Document;
import org.w3c.dom.Node;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;

public class StringXmlUtil {

    /**
     * @param document Document对象（读xml生成的）
     * @return String字符串
     * @throws Throwable
     */
    public static String xmlToString(Document document) throws Throwable {
        TransformerFactory ft = TransformerFactory.newInstance();
        Transformer ff = ft.newTransformer();
        ff.setOutputProperty("encoding", "UTF-8");
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ff.transform(new DOMSource(document), new StreamResult(bos));
        return bos.toString();
    }

    /**
     * @param str xml形状的str串
     * @return Document 对象
     */
    public static Document stringToXml(String str) {

        StringBuilder sXML = new StringBuilder();
        sXML.append(str);
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        Document doc = null;
        try {
            InputStream is = new ByteArrayInputStream(sXML.toString().getBytes("utf-8"));
            doc = dbf.newDocumentBuilder().parse(is);
            is.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return doc;
    }

    /**
     * @param document
     * @return 某个节点的值 前提是需要知道xml格式，知道需要取的节点相对根节点所在位置
     */
    public static String getNodeValue(Document document, String nodePaht) {
        XPathFactory xpfactory = XPathFactory.newInstance();
        XPath path = xpfactory.newXPath();
        String servInitrBrch = "";
        try {
            servInitrBrch = path.evaluate(nodePaht, document);
        } catch (XPathExpressionException e) {
            e.printStackTrace();
        }
        return servInitrBrch;
    }

    /**
     * @param document
     * @param nodePath  需要修改的节点相对根节点所在位置
     * @param vodeValue 替换的值
     */
    public void setNodeValue(Document document, String nodePath, String vodeValue) {
        XPathFactory xpfactory = XPathFactory.newInstance();
        XPath path = xpfactory.newXPath();
        Node node = null;
        try {
            node = (Node) path.evaluate(nodePath, document, XPathConstants.NODE);
        } catch (XPathExpressionException e) {
            e.printStackTrace();
        }
        node.setTextContent(vodeValue);
    }

}
