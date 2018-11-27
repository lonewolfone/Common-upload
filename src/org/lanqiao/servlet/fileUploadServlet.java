package org.lanqiao.servlet;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;

@javax.servlet.annotation.WebServlet( "/fileUploadServlet")
public class fileUploadServlet extends javax.servlet.http.HttpServlet {
    protected void doPost(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response) throws javax.servlet.ServletException, IOException {
        doGet(request, response);
    }

    protected void doGet(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response) throws javax.servlet.ServletException, IOException {
        //创建一个工厂
        DiskFileItemFactory factory = new DiskFileItemFactory();
        //创建一个文件处理器
        ServletFileUpload upload = new ServletFileUpload(factory);
        //解析request请求(解析器解析上传数据)，解析结果返回的是一个List<FileItem>集合，每一个FileItem对应一个Form表单的输入项
        List<FileItem> items = null;
        try {
             items = upload.parseRequest(request);
        } catch (FileUploadException e) {
            e.printStackTrace();
        }
        //获取集合迭代器
        Iterator<FileItem> fileItemIterator = items.iterator();
        //循环(迭代)：获得文件或表单
        while (fileItemIterator.hasNext()){
           FileItem fileItem = fileItemIterator.next();
           //判断其是否为表单字段，还是文件
           if (!fileItem.isFormField()){
               //表单控件name属性
              String formName =   fileItem.getFieldName();
              //获取文件名称：不同的浏览器提交的文件名是不一样的，有些浏览器提交上来的文件名是带有路径的，如：  c:\a\b\1.txt，而有些只是单纯的文件名，如：1.txt
              String name =   fileItem.getName();
               System.out.println("在IE浏览器中提交上来的文件名是带有路径的：name："+name);
              //获取文件名称：
              File tempFile = new File(name.trim());
              String fileName =  tempFile.getName();
              //上传类型
              String contentType = fileItem.getContentType();
              //是否在内存中
              boolean isInMemory = fileItem.isInMemory();
              //文件大小
              double size = fileItem.getSize();
               System.out.println("formName:"+formName);
               System.out.println("fileName:"+fileName);
               System.out.println("contentType:"+contentType);
               System.out.println("isInMemory:"+isInMemory);
               System.out.println("size:"+size);
              //上传文件
               File uploadFile = new File("f://aa/"+fileName);
               try {
                   //fileItem.write(uploadFile);
                   FileUtils.copyInputStreamToFile(fileItem.getInputStream(),uploadFile);
                   //删除处理文件上传时生成的临时文件
                   fileItem.delete();
               } catch (Exception e) {
                   e.printStackTrace();
               }
           }

        }
    }
}
