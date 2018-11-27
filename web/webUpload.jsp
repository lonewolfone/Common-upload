<%--
  Created by IntelliJ IDEA.
  User: 听音乐的酒
  Date: 2018/11/26
  Time: 11：14
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>webUpload组件的使用</title>
    <%--引入css--%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/webuploader.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap-theme.css">
    <%--引入js--%>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-1.12.4.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/webuploader.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/bootstrap.js"></script>
    <style type="text/css">
        .placeholder {
            min-height: 350px;
            padding-top: 178px;
            text-align: center;
            background: url(http://fex.baidu.com/webuploader/images/image.png) center 93px no-repeat;
            color: #cccccc;
            font-size: 18px;
            position: relative;
        }
    </style>
    <script type="text/javascript">
        $(function () {
            var fileMd5;
            //监听分块上传过程中的三个时间点
            WebUploader.Uploader.register({
                "before-send-file":"beforeSendFile",
                "before-send":"beforeSend",
                "after-send-file":"afterSendFile",
            },{
                //时间点1：所有分块进行上传之前调用此函数
                beforeSendFile:function(file){
                    var deferred = WebUploader.Deferred();
                    //1、计算文件的唯一标记，用于断点续传
                    (new WebUploader.Uploader()).md5File(file,0,10*1024*1024)
                        .progress(function(percentage){
                            $("#"+file.id).find("div.state").text("正在读取文件信息...");
                        })
                        .then(function(val){
                            fileMd5=val;
                            $("#"+file.id).find("div.state").text("成功获取文件信息...");
                            //获取文件信息后进入下一步
                            deferred.resolve();
                        });
                    return deferred.promise();
                },
                //时间点2：如果有分块上传，则每个分块上传之前调用此函数
                beforeSend:function(block){
                    var deferred = WebUploader.Deferred();

                    $.ajax({
                        type:"POST",
                        url:"${pageContext.request.contextPath}/video?action=checkChunk",
                        data:{
                            //文件唯一标记
                            fileMd5:fileMd5,
                            //当前分块下标
                            chunk:block.chunk,
                            //当前分块大小
                            chunkSize:block.end-block.start
                        },
                        dataType:"json",
                        success:function(response){
                            if(response.ifExist){
                                //分块存在，跳过
                                deferred.reject();
                            }else{
                                //分块不存在或不完整，重新发送该分块内容
                                deferred.resolve();
                            }
                        }
                    });

                    this.owner.options.formData.fileMd5 = fileMd5;
                    deferred.resolve();
                    return deferred.promise();
                },
                //时间点3：所有分块上传成功后调用此函数
                afterSendFile:function(){
                    //如果分块上传成功，则通知后台合并分块
                    $.ajax({
                        type:"POST",
                        url:"${pageContext.request.contextPath}/video?action=mergeChunks",
                        data:{
                            fileMd5:fileMd5,
                        },
                        success:function(response){
                            alert("上传成功");
                            var path = "uploads/"+fileMd5+".mp4";
                            $("#item1").attr("src",path);
                        }
                    });
                }
            });
            var uploader = WebUploader.create({
                // swf文件路径
                swf:  '${pageContext.request.contextPath}/js/Uploader.swf',
                // 文件接收服务端。
                server: '${pageContext.request.contextPath}/WebUploadServlet',
                // 选择文件的按钮。可选。
                // 内部根据当前运行是创建，可能是input元素，也可能是flash.
                pick: '#picker',
                // 不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
                resize: false,
                //开启拖拽功能，指定拖拽区域
                dnd:"#dndArea",
                //禁用页面其他地方的拖拽功能，防止页面直接打开文件
                disableGlobalDnd:true,
                //开启黏贴功能
                paste:"#uploader",
                //分块上传设置
                //是否分块上传
                chunked:true,
                //每块文件大小（默认5M）
                chunkSize:5*1024*1024,
                //开启几个并发线程（默认3个）
                threads:3,
                //在上传当前文件时，准备好下一个文件
                prepareNextFile:true,
                auto:true
            });
            // 当有文件被添加进队列的时候
            // 当有文件添加进来的时候
            uploader.on( 'fileQueued', function( file ) {
                var $list = $("#thelist");
                var $li = $(
                    '<div id="' + file.id + '" class="file-item thumbnail">' +
                    '<img>' +
                    '<div class="info">' + file.name + '</div>' +
                    '<p class="state">等待上传...</p>' +
                    '</div>'
                    ),
                    $img = $li.find('img');
                // $list为容器jQuery实例
                $list.append($li);
                // 创建缩略图
                // 如果为非图片文件，可以不用调用此方法。
                // thumbnailWidth x thumbnailHeight 为 100 x 100

                uploader.makeThumb(file, function (error, src) {
                    if (error) {
                        $img.replaceWith('<span>不能预览</span>');
                        return;
                    }
                    $img.attr('src', src);
                },100,100);
            });
            /*
            before-send-file : 在所有分块发送之前调用
            before-send: 如果有分块，在每个分块发送之前调用
            after-send-file: 在所有分块发送完成之后调用
             */
            // 文件上传过程中创建进度条实时显示。
            uploader.on( 'uploadProgress', function( file, percentage ) {
                var $li = $( '#'+file.id ),
                    $percent = $li.find('.progress .progress-bar');

                // 避免重复创建
                if ( !$percent.length ) {
                    $percent = $('<div class="progress progress-striped active" style="width: 100px">' +
                        '<div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"  style="width: 0% ;background-color:green">' +
                        '</div>' +
                        '</div>').appendTo( $li ).find('.progress-bar');
                }

                $li.find('p.state').text('上传中');
                $percent.css( 'width', percentage * 100 + '%' );

            });
            uploader.on( 'uploadSuccess', function( file ) {
                $( '#'+file.id ).find('p.state').text('上传成功');
            });
        })

    </script>
</head>
<body>
        <div id="uploader" class="wu-example">

            <!--用来存放文件信息-->
            <div id="thelist" class="uploader-list">
                上传的文件列表<br>
            </div><br>

            <div class="btns">
                <div id="dndArea" class="webuploader-container placeholder">
                    请将文件拖放到此处<br>
                    <div id="picker">选择文件</div>
                </div><br>
                <button id="ctlBtn" class="btn btn-default">开始上传</button>
            </div>
        </div>
</body>
</html>
