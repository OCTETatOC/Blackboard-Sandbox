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

<%!
	// Find a PortalRole through the quick-and-dirty instance of the PortalRoleDbLoader class.
	public PortalRole getPortalRoleByName(String roleName) throws PersistenceException
	{
		return getPortalRoleByName(PortalRoleDbLoader.Default.getInstance(), roleName);
	}

	// Find a PortalRole through the given PortalRoleDbLoader.
	public PortalRole getPortalRoleByName(PortalRoleDbLoader roleLoader, String roleName) throws PersistenceException
	{
		return getPortalRoleByName(roleLoader.loadAll(), roleName);
	}

	// Take in some iterable data structure of PortalRoles and see if any of them return roleName from their getRoleName method.
	// If so, return that PortalRole. If not, return null.
	public PortalRole getPortalRoleByName(Iterable<PortalRole> portalRoles, String roleName)
	{
		for(PortalRole portalRole : portalRoles)
		{
			if(portalRole.getRoleName().equals(roleName))
			{
				return portalRole;
			}
		}
		return null;
	}
%>

<!--
	TEST DESCRIPTION:
			This test initially investigated how the UserDbLoader class's
		loadByUserSearch method can be used to find a list of enabled users
		through caseless search. The UserDbLoader worked as expected.
			This test then added an attempt to probe whether all users are
		available or not. Not all were.
			This test then addressed the possibility of filtering the List of
		User objects returned from the UserDbLoader class's loadByUserSearch
		method for availability via the ListFilter class. The ListFilter worked
		as expected.
			This test then addressed the possibility of adding another filter to
		examine the PortalRole of each User in order to display only students.
		The User objects returned by the UserDbLoader's loadByUserSearch method
		all returned an unset ID object from their getPortalRoleId method,
		rendering this filtering method ineffective.
			This test then addressed the possibility of utilizing the
		PortalRoleDbLoader's loadPrimaryRoleByUserId method for each User object
		returned by the UserDbLoader's loadByUserSearch method in order to
		retrieve their PortalRole and compare it with the Student's PortalRole,
		as well as performing a manual probing of the User object's
		getIsAvailable method instead of using a ListFilter. The PortalRole
		objects returned by the PortalDbLoader's loadPrimaryRoleByUserId method
		were non-null, and in many cases returned "Student" from their
		getRoleName method; however, the equality test between these roles and
		the studentPortalRole were never successful.
			This test then attempted to use the getId methods of
		studentPortalRole and each User object's primary PortalRole to test for
		equality instead. It ran successfully, and was efficient enough to
		process every BlackBoard user in one to two seconds. One side
		observation is that, even when examining every user, no unavailable
		users were located.
			As a finishing, slightly tangential touch, this test attempted to
		declare a getPortalRoleByName method to mimic the intended effects of
		the PortalRoleDbLoader's loadByRoleName method (which does not work). It
		was successful, and the method has been pushed to the sandbox repository
		on GitHub.
-->

<%
	/*
		This is where your test should go. The TEST DESCRIPTION area above will
		appear in the final HTML source code for the actual page, just in case
		it needs to be visible to everyone viewing the testing tool from
		BlackBoard.
	*/
	String lastNameQuery = request.getParameter("name");
	%>
		<form action="courseToolSandbox.jsp" method="post" id="lastnamequery">
			<input type="text" name="name" value="<%=lastNameQuery == null ? "" : lastNameQuery%>">
			<input type="submit" value="Submit">
		</form>
	<%
	if(lastNameQuery != null)
	{
		PortalRole studentPortalRole = getPortalRoleByName("Student");

		if(studentPortalRole != null)
		{
			Id studentPortalRoleId = studentPortalRole.getId();

			UserSearch userSearch = new UserSearch();
			userSearch.addParameter(new UserSearch.SearchParameter(UserSearch.SearchKey.FamilyName, lastNameQuery, SearchOperator.Contains));
			userSearch.setOnlyShowEnabled(true);
			List<User> users = userLoader.loadByUserSearch(userSearch);

			int availableStudents = 0;
			int unavailableStudents = 0;
			int availableNonStudents = 0;
			int unavailableNonStudents = 0;

			for(User user : users)
			{
				PortalRole currentPortalRole = portalRoleLoader.loadPrimaryRoleByUserId(user.getId());
				boolean isAvailable = user.getIsAvailable();
				boolean isStudent = currentPortalRole != null ? studentPortalRoleId.equals(currentPortalRole.getId()) : false;
				out.println("<div>" + user.getGivenName() + " " + user.getFamilyName() + " is an ");
				if(isAvailable && isStudent)
				{
					out.println("available student.</div>");
					availableStudents++;
				}
				else if(!isAvailable && isStudent)
				{
					out.println("unavailable student.</div>");
					unavailableStudents++;
				}
				else if(isAvailable && !isStudent)
				{
					out.println("available non-student with a portal role of " + (currentPortalRole != null ? currentPortalRole.getRoleName() : "null") + ".</div>");
					availableNonStudents++;
				}
				else if(!isAvailable && !isStudent)
				{
					out.println("unavailable non-student.</div>");
					unavailableNonStudents++;
				}
			}
			out.println("<h1>In total, there are " + availableStudents + " available students, " + unavailableStudents + " unavailable students, " + availableNonStudents + " available non-students, and " + unavailableNonStudents + " unavailable non-students.</h1>");
		}
		else
		{
			out.println("<div>The Student PortalRole could not be located.</div>");
		}
	}
%>

<script>
	document.getElementById("lastnamequery").name.focus();
</script>

</bbUI:docTemplate>
</bbData:context>
