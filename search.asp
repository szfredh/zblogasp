<%@ CODEPAGE=65001 %>
<%
'///////////////////////////////////////////////////////////////////////////////
'//              Z-Blog
'// 作    者:    朱煊(zx.asd)
'// 版权所有:    RainbowSoft Studio
'// 技术支持:    rainbowsoft@163.com
'// 程序名称:    
'// 程序版本:    
'// 单元名称:    search.asp
'// 开始时间:    2005.02.17
'// 最后修改:    
'// 备    注:    站内搜索
'///////////////////////////////////////////////////////////////////////////////
%>
<% Option Explicit %>
<% 'On Error Resume Next %>
<% Response.Charset="UTF-8" %>
<% Response.Buffer=True %>
<!-- #include file="zb_users/c_option.asp" -->
<!-- #include file="zb_system/function/c_function.asp" -->
<!-- #include file="zb_system/function/c_system_lib.asp" -->
<!-- #include file="zb_system/function/c_system_base.asp" -->
<!-- #include file="zb_system/function/c_system_event.asp" -->
<!-- #include file="zb_system/function/c_system_plugin.asp" -->
<!-- #include file="zb_users/plugin/p_config.asp" -->
<%

Call System_Initialize()

'plugin node
For Each sAction_Plugin_Searching_Begin in Action_Plugin_Searching_Begin
	If Not IsEmpty(sAction_Plugin_Searching_Begin) Then Call Execute(sAction_Plugin_Searching_Begin)
Next

TemplateTagsDic.Item("ZC_BLOG_HOST")=GetCurrentHost()

'检查权限
If Not CheckRights("Search") Then Call ShowError(6)

Dim strQuestion
strQuestion=TransferHTML(Request.QueryString("q"),"[nohtml]")

Dim objArticle
Set objArticle=New TArticle

objArticle.LoadCache




Dim i
Dim j
Dim s
Dim aryArticleList()

Dim objRS
Dim intPageCount
Dim objSubArticle

Dim cate
If IsEmpty(Request.QueryString("cate"))=False Then
cate=CInt(Request.QueryString("cate"))
End If


strQuestion=Trim(strQuestion)

'If Len(strQuestion)=0 Then Search=True:Exit Function

strQuestion=FilterSQL(strQuestion)

Set objRS=Server.CreateObject("ADODB.Recordset")
objRS.CursorType = adOpenKeyset
objRS.LockType = adLockReadOnly
objRS.ActiveConnection=objConn

objRS.Source="SELECT [log_ID],[log_Tag],[log_CateID],[log_Title],[log_Intro],[log_Content],[log_Level],[log_AuthorID],[log_PostTime],[log_CommNums],[log_ViewNums],[log_TrackBackNums],[log_Url],[log_Istop],[log_Template],[log_FullUrl],[log_IsAnonymous],[log_Meta] FROM [blog_Article] WHERE ([log_CateID]>0) And ([log_ID]>0) AND ([log_Level]>2)"

If ZC_MSSQL_ENABLE=False Then
	objRS.Source=objRS.Source & "AND( (InStr(1,LCase([log_Title]),LCase('"&strQuestion&"'),0)<>0) OR (InStr(1,LCase([log_Intro]),LCase('"&strQuestion&"'),0)<>0) OR (InStr(1,LCase([log_Content]),LCase('"&strQuestion&"'),0)<>0) )"
Else
	objRS.Source=objRS.Source & "AND( (CHARINDEX('"&strQuestion&"',[log_Title])<>0) OR (CHARINDEX('"&strQuestion&"',[log_Intro])<>0) OR (CHARINDEX('"&strQuestion&"',[log_Content])<>0) )"
End If

If IsEmpty(cate)=False Then
	objRS.Source=objRS.Source & "AND ([log_CateID]="&cate&")"
End If

objRS.Source=objRS.Source & "ORDER BY [log_PostTime] DESC,[log_ID] DESC"
objRS.Open()

's=Replace(Replace(ZC_MSG086,"%s","<strong>" & TransferHTML(Replace(strQuestion,Chr(39)&Chr(39),Chr(39)),"[html-format]") & "</strong>",vbTextCompare,1),"%s","<strong>" & objRS.RecordCount & "</strong>")
s=Replace(Replace(ZC_MSG086,"%s","<strong>" & TransferHTML(Replace(strQuestion,Chr(39)&Chr(39),Chr(39),1,-1,0),"[html-format]") & "</strong>",vbTextCompare,1),"%s","<strong>" & objRS.RecordCount & "</strong>",1,-1,0)

If (Not objRS.bof) And (Not objRS.eof) Then
	objRS.PageSize = ZC_SEARCH_COUNT
	intPageCount=objRS.PageCount
	objRS.AbsolutePage = 1

	For i = 1 To objRS.PageSize

		ReDim Preserve aryArticleList(i)

		Set objSubArticle=New TArticle
		If objSubArticle.LoadInfoByArray(Array(objRS(0),objRS(1),objRS(2),objRS(3),objRS(4),objRS(5),objRS(6),objRS(7),objRS(8),objRS(9),objRS(10),objRS(11),objRS(12),objRS(13),objRS(14),objRS(15),objRS(16),objRS(17))) Then
			objSubArticle.SearchText=Request.QueryString("q")
			If objSubArticle.Export(ZC_DISPLAY_MODE_SEARCH)= True Then
				aryArticleList(i)=objSubArticle.subhtml
			End If
		End If
		Set objSubArticle=Nothing

		objRS.MoveNext
		If objRS.EOF Then Exit For

	Next

Else
	ReDim Preserve aryArticleList(0)
End If

objRS.Close()
Set objRS=Nothing

objArticle.Content=Join(aryArticleList)

objArticle.Title=ZC_MSG085 + ":" + TransferHTML(strQuestion,"[html-format]")

If objArticle.Export(ZC_DISPLAY_MODE_ONLYPAGE) Then
	objArticle.Build
	Response.Write objArticle.html
End If

'plugin node
For Each sAction_Plugin_Searching_End in Action_Plugin_Searching_End
	If Not IsEmpty(sAction_Plugin_Searching_End) Then Call Execute(sAction_Plugin_Searching_End)
Next

Call System_Terminate()

%><!-- <%=RunTime()%>ms --><%
If Err.Number<>0 then
	Call ShowError(0)
End If
%>