package org.lanqiao.servlet;

import org.apache.commons.io.IOUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

@WebServlet( "/fileDownloadServlet")
public class fileDownloadServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取要下载的文件名称(实际开发中：从数据库中获取)
        String fileName =  request.getParameter("filename");
        //设置文件响应的内容类型，不再是直接响应一个html页面  而是要响应下载
        response.setContentType("application/x-msdownload");
        //获取文件所在的路径
        String filePath = request.getServletContext().getRealPath("/WEB-INF/imgs/"+fileName);
        //获取文件
        File file = new File(filePath);
        //判断文件是否存在
        if(!file.exists()){
            System.out.println("您下载的文件不存在");
        }
        //解决中文乱码问题
        fileName = new String(fileName.getBytes("UTF-8"),"ISO-8859-1");
        //下载框中显示正确的文件名称
        response.addHeader("content-disposition","attachment;filename="+fileName);
        //将文件从服务端下载到客户端: 响应输出流
        IOUtils.copy(new FileInputStream(file),response.getOutputStream());
    }
}
