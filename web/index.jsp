<%--
  Created by IntelliJ IDEA.
  User: 听音乐的酒
  Date: 2018/11/23
  Time: 14:28
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>文件的上传下载</title>
  </head>
  <body>
          <%--
              文件上传表单：其中method  必须是post
              enctype:multipart/form-data
              文件上传的表单控件：input type="file"
          --%>
          <h3>文件的上传</h3>
          <form action="/fileUploadServlet" method="post" enctype="multipart/form-data">
              <input type="file" name="uploadFile"><br><br>
              <input type="submit" value="提交"><br><br>
          </form>

          <h3>文件的下载</h3>
          <%--请求Servlet,参数：获取那个文件--%>
          <a href="/fileDownloadServlet?filename=02.jpg">02.jpg</a>
          <a href="/fileDownloadServlet?filename=03.jpg">03.jpg</a>
          <a href="/fileDownloadServlet?filename=04.jpg">04.jpg</a>
  </body>
</html>
