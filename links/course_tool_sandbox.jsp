<%@page import="java.util.*,
				blackboard.admin.data.user.*,
				blackboard.admin.data.IAdminObject,
				blackboard.admin.persist.user.*,
				blackboard.base.*,
				blackboard.data.*,
                blackboard.data.user.*,
				blackboard.data.course.*,
				blackboard.data.role.*,
                blackboard.persist.*,
                blackboard.persist.user.*,
				blackboard.persist.role.*,
				blackboard.persist.course.*,
                blackboard.platform.*,
                blackboard.platform.persistence.*"
        errorPage="/error.jsp"
%>

<%@ taglib uri="/bbData" prefix="bbData"%>
<%@ taglib uri="/bbUI" prefix="bbUI"%>

<bbData:context id="ctx">
<bbUI:docTemplate title="OCTET Sandbox">

<%
	/*
		This is all setup code for accessing databases. You may need all, some,
		or even none of it, depending on what you want to test. None of it
		should be resource-intensive enough to affect performance, so don't
		worry about leaving it all in even if none of it's used.
	*/
	BbPersistenceManager persistenceManager = BbServiceManager.getPersistenceService().getDbPersistenceManager();
	PortalRoleDbLoader portalRoleLoader = (PortalRoleDbLoader)persistenceManager.getLoader(PortalRoleDbLoader.TYPE);
	UserDbLoader userLoader = (UserDbLoader)persistenceManager.getLoader(UserDbLoader.TYPE);
	PersonLoader personLoader = (PersonLoader)persistenceManager.getLoader(PersonLoader.TYPE);
%>

<!--
	TEST DESCRIPTION:
-->

<%
	/*
		This is where your test should go. The TEST DESCRIPTION area above will
		appear in the final HTML source code for the actual page, just in case
		it needs to be visible to everyone viewing the testing tool from
		BlackBoard.
	*/
%>

</bbUI:docTemplate>
</bbData:context>
