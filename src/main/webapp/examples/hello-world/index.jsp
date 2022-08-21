<%@ page import="canvas.SignedRequest" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Enumeration" %>
<%
    // Pull the signed request out of the request body and verify/decode it.
    Map<String, String[]> parameters = request.getParameterMap();
    String[] signedRequest = parameters.get("signed_request");
    if (signedRequest == null) {
        out.println("This App must be invoked via a signed request!");
        return;
    }
    String yourConsumerSecret=System.getenv("CANVAS_CONSUMER_SECRET");
    String signedRequestJson = SignedRequest.verifyAndDecodeAsJson(signedRequest[0], yourConsumerSecret);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>

    <title>Hello World Canvas Example</title>

    <link rel="stylesheet" type="text/css" href="/sdk/css/canvas.css" />

    <!-- Include all the canvas JS dependencies in one file -->
    <script type="text/javascript" src="/sdk/js/canvas-all.js"></script>
    <!-- Third part libraries, substitute with your own -->
    <script type="text/javascript" src="/scripts/json2.js"></script>

    <script>
        if (self === top) {
            // Not in Iframe
            alert("This canvas app must be included within an iframe");
        }
        
        function canvasCallback(){
        	var sr = JSON.parse('<%=signedRequestJson%>');
        	Sfdc.canvas.oauth.token(sr.oauthToken);
        	Sfdc.canvas.byId('application').innerHTML = JSON.stringify(sr.context.application);
            Sfdc.canvas.byId('user').innerHTML = JSON.stringify(sr.context.user);
            Sfdc.canvas.byId('record.attributes').innerHTML = JSON.stringify(sr.context.environment.record.attributes);
            Sfdc.canvas.byId('params').innerHTML = JSON.stringify(sr.context.environment.parameters);
            
        }

        Sfdc.canvas(canvasCallback);

    </script>
</head>
<body>
	<h1>Context.Application = </h1>
	<div id='application'></div>
    <h1>Context.User = </h1> 
    <div id='user'></div>
    <h1>Context.Record.Attributes = </h1>   
    <div id='record.attributes'></div>
    <h1>Context.Parameters = </h1>
    <div id='params'></div>
   
</body>
</html>
