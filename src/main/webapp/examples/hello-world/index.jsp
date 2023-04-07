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

    <link rel="stylesheet" type="text/css" href="/sdk/css/salesforce-lightning-design-system.min.css" />

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
        	console.log("SR:"+ JSON.stringify(sr) );
        	Sfdc.canvas.oauth.token(sr.oauthToken);
        	Sfdc.canvas.byId('application').innerHTML = JSON.stringify(sr.context.application);
        	Sfdc.canvas.byId('user').innerHTML = JSON.stringify(sr.context.user);
            Sfdc.canvas.byId('dimensions').innerHTML = JSON.stringify(sr.context.environment.dimensions);
            Sfdc.canvas.byId('record').innerHTML = JSON.stringify(sr.context.environment.record);
            Sfdc.canvas.byId('params').innerHTML = JSON.stringify(sr.context.environment.parameters);
            Sfdc.canvas.byId('accountId').innerHTML = JSON.stringify(sr.context.environment.parameters.accountId);
            var accountLink = sr.client.instanceUrl +"/"+ sr.context.environment.parameters.accountId;
            console.log("accountLink:"+ accountLink);
            Sfdc.canvas.byId('accountLink').href = accountLink;
            console.log("Client:"+ sr.context.environment.dimensions.clientWidth);
            console.log("Client:"+ sr.context.environment.dimensions.clientHeight);
            //Sfdc.canvas.client.resize(sr.client, {height : sr.context.environment.dimensions.clientHeight,width : sr.context.environment.dimensions.clientWidth});
            Sfdc.canvas.client.resize(sr.client);
            Sfdc.canvas.client.autogrow(sr.client);
            
        }
        
        function openAccountLink(){
        	var accountLink = document.getElementById("accountLink").href ;
        	window.open(accountLink,'popup','width=600,height=600,scrollbars=no,resizable=no'); 
        	return false;
        	
        }

        Sfdc.canvas(canvasCallback);
        

    </script>
</head>
<body>
	<div id="wrapper" style="text-align:center" class="slds-grid slds-gutters slds-grid_vertical">
		<div id="container" style="display:inline-block;text-align:left" class="slds-grid slds-gutters slds-grid_vertical">
			
			<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Application = </h1> <p id='application'></p>
	    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.User = </h1> <p id='user'></p>
	    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Environment.Dimensions with Auto Resize = </h1> <p id='dimensions'></p>
	    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Environment.Record = </h1> <p id='record'></p>
	    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Enviroment.Parameters = </h1> <p id='params'></p>
	    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Enviroment.Parameters.accountId = </h1> <p id='accountId'></p>
	    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">AccountLink</h1> <a id=accountLink href="https://www.w3schools.com" target="popup" onClick="openAccountLink()">Open AccountLink</a>
	    	
		 
		</div>
	</div>
   
</body>
</html>
