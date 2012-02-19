<%@ page import="java.util.Enumeration" %>
<%--
  Created by IntelliJ IDEA.
  User: markw
  Date: Mar 22, 2009
  Time: 9:12:28 AM
--%>
<%
    Boolean publish_html = true;
    Boolean publish_rdf_n3 = false;
    Enumeration accepts = request.getHeaders("accept");
    while (accepts.hasMoreElements()) {
        String key = "" + accepts.nextElement();
        if (key.indexOf("rdf+n3") > -1) {
            publish_html = false;
            publish_rdf_n3 = true;
        }
    }
    if (publish_rdf_n3) {
%>
<%@ include file="test.n3" %>

<% } else if (publish_html) {
%>
<%@ include file="test.html" %>
<%
    }
%>
