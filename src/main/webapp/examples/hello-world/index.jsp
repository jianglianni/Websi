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
        
    	
    	var sr = {};
    	
        function canvasCallback(){
    		sr = JSON.parse('<%=signedRequestJson%>');
        	//console.log("SR:"+ JSON.stringify(sr) );
        	Sfdc.canvas.oauth.token(sr.oauthToken);
        	
        	canvasAppEventId = sr.context.environment.parameters.canvasAppEventId;
        	populateContextValues(sr);
	        
        	getAccountInsights();

            console.log("Client:"+ sr.context.environment.dimensions.clientWidth);
            console.log("Client:"+ sr.context.environment.dimensions.clientHeight);
            Sfdc.canvas.client.resize(sr.client, {height : sr.context.environment.dimensions.clientHeight,width : sr.context.environment.dimensions.clientWidth});
            //Sfdc.canvas.client.resize(sr.client);
            Sfdc.canvas.client.autogrow(sr.client);
                        
        }
        
        function populateContextValues(sr){
        	Sfdc.canvas.byId('application').innerHTML = JSON.stringify(sr.context.application);
        	Sfdc.canvas.byId('user').innerHTML = JSON.stringify(sr.context.user);
            Sfdc.canvas.byId('dimensions').innerHTML = JSON.stringify(sr.context.environment.dimensions);
            Sfdc.canvas.byId('record').innerHTML = JSON.stringify(sr.context.environment.record);
            Sfdc.canvas.byId('params').innerHTML = JSON.stringify(sr.context.environment.parameters);
            Sfdc.canvas.byId('accountId').innerHTML = JSON.stringify(sr.context.environment.parameters.accountId);
            var accountLink = sr.client.instanceUrl +"/"+ sr.context.environment.parameters.accountId;
            console.log("accountLink:"+ accountLink);
            Sfdc.canvas.byId('accountLink').href = accountLink;
            
        }
        
        function openAccountLink(){
        	var accountLink = document.getElementById("accountLink").href ;
        	window.open(accountLink,'popup','width=600,height=600,scrollbars=no,resizable=no'); 
        	return false;
        	
        }
        
        function getAccountInsights() {
			// Get Account Insights
			var url = sr.context.links.queryUrl + "?q=Select Id,Insight_Id__c,Name From Account_Insight__c Where Account__c=\'"+sr.context.environment.parameters.accountId+"\' AND Status__c=\'Open\' Order By Name";
			console.log("getAccountInsights="+url)
			Sfdc.canvas.client.ajax(url, {
				client: sr.client,
				success: function (data) {
					if (data.status === 200) {
						console.log("getAccountInsights.data.payload.records="+JSON.stringify(data.payload.records));
						data.payload.records.forEach((record) => {
							console.log("record.Id="+record.Id);
							console.log("record.Name="+record.Name);
							let insightList = document.querySelector("#insight-list")
							let newInsight = insightList.insertRow(-1);
							console.log("newInsight="+newInsight);
							//Name
							let recordNameCell = newInsight.insertCell(0);
							let recordNameTd = document.createElement("td");
							recordNameTd.setAttribute("data-label","Name");
							let recordNameDiv = document.createElement("div");
							recordNameDiv.className = "slds-truncate";
							recordNameDiv.title = record.Name;
							recordNameDiv.textContent = record.Name;
							recordNameTd.appendChild(recordNameDiv);
							recordNameCell.appendChild(recordNameTd);
							console.log("recordNameCell="+recordNameCell);
							
							
							//Id
							let recordIdCell = newInsight.insertCell(1);
							let recordIdTd = document.createElement("td");
							recordIdTd.setAttribute("data-label","Id");
							let recordIdDiv = document.createElement("div");
							recordIdDiv.className = "slds-truncate";
							recordIdDiv.title = record.Id;
							recordIdDiv.textContent = record.Id;
							recordIdTd.appendChild(recordIdDiv);
							recordIdCell.appendChild(recordIdTd);
							
							console.log("recordIdCell="+recordIdCell);
							
							
							//Insight Id
							let insightIdCell = newInsight.insertCell(2);
							let insightIdTd = document.createElement("td");
							insightIdTd.setAttribute("data-label","Insight Id");
							let insightIdDiv = document.createElement("div");
							insightIdDiv.className = "slds-truncate";
							insightIdDiv.title = record.Insight_Id__c;
							insightIdDiv.textContent = record.Insight_Id__c;
							insightIdTd.appendChild(insightIdDiv);
							insightIdCell.appendChild(insightIdTd);
							console.log("insightIdCell="+insightIdCell);
							
								
							//Review Tasks- LM
							let lmRecordTaskCell = newInsight.insertCell(3);
							let lmRecordTaskTd = document.createElement("td");
							lmRecordTaskTd.setAttribute("data-label","Javascript/Lightning Message");
							let lmRecordTaskButton = document.createElement("button");
							lmRecordTaskButton.id = record.Id;
							lmRecordTaskButton.value = record.Insight_Id__c;
							lmRecordTaskButton.className="slds-button slds-button_brand";
							lmRecordTaskButton.innerText = "LM Recommended Actions";
							lmRecordTaskButton.onclick = sendCanvasAppEventLM;
							lmRecordTaskTd.appendChild(lmRecordTaskButton);
							lmRecordTaskCell.appendChild(lmRecordTaskTd);
							console.log("lmRecordTaskCell="+lmRecordTaskCell);
							
							
							//Review Tasks- SE
							let seRecordTaskCell = newInsight.insertCell(4);
							let seRecordTaskTd = document.createElement("td");
							seRecordTaskTd.setAttribute("data-label","Push Topic");
							let seRecordTaskButton = document.createElement("button");
							seRecordTaskButton.id = record.Id;
							seRecordTaskButton.value = record.Insight_Id__c;
							seRecordTaskButton.className="slds-button slds-button_brand";
							seRecordTaskButton.innerText = "SE Recommended Actions";
							seRecordTaskButton.onclick = updateCanvasAppEvent;
							seRecordTaskTd.appendChild(seRecordTaskButton);
							seRecordTaskCell.appendChild(seRecordTaskTd);
							console.log("seRecordTaskCell="+seRecordTaskCell);
							

							//Review Tasks- PE
							let peRecordTaskCell = newInsight.insertCell(5);
							let peRecordTaskTd = document.createElement("td");
							peRecordTaskTd.setAttribute("data-label","Platform Event");
							let peRecordTaskButton = document.createElement("button");
							peRecordTaskButton.id = record.Id;
							peRecordTaskButton.value = record.Insight_Id__c;
							peRecordTaskButton.className="slds-button slds-button_brand";
							peRecordTaskButton.innerText = "PE Recommended Actions";
							peRecordTaskButton.onclick = postToPlatformEvent;
							peRecordTaskTd.appendChild(peRecordTaskButton);
							peRecordTaskCell.appendChild(peRecordTaskTd);
							console.log("peRecordTaskCell="+peRecordTaskCell);
							
							
						
						});
					}
				},
			});
		}
        
        function postToPlatformEvent(e) {
        	//alert(e.target.id);
			var url = sr.context.links.sobjectUrl + "Canvas_App_PE__e";
			console.log("postToPlatformEvent:url="+ url);
			var eventData = {
				"Account_Id__c": sr.context.environment.parameters.accountId,
				"Logged_In_User_Id__c": sr.context.user.userId,
				"Account_Insight_Id__c":e.target.id,
				"Insight_Id__c":e.target.value,
				"Refresh_Nba__c": true	
			};
			console.log("postToPlatformEvent:eventData="+ JSON.stringify(eventData));
			Sfdc.canvas.client.ajax(url, {
				client: sr.client,
				method: "POST",
				contentType: "application/json",
				data: JSON.stringify(eventData),
				success: function (data) {
					if (201 === data.status) {
						console.log("postToPlatformEvent Sucess");
					}
				},
			});
		}
        
        function updateCanvasAppEvent(e) {
        	
        	//alert(e.target.id);
        	
        	
			var url = sr.context.links.sobjectUrl + "Canvas_App_Event__c/"+sr.context.environment.parameters.canvasAppEventId;
			console.log("updateCanvasAppEvent:url="+ url);
			var updateData = {
				"Account_Insight__c":e.target.id
					
			};
			// Send canvas javascript event.
    		//Sfdc.canvas.client.publish(sr.client,{name : 'sfgbi.sendVal',payload : JSON.stringify(updateData)});
    		//alert('CanvasApp Publised Event');
    		//sendCanvasAppEventLM(e);
        	
			console.log("updateCanvasAppEvent:updateData="+ JSON.stringify(updateData));
			Sfdc.canvas.client.ajax(url, {
				client: sr.client,
				method: "PATCH",
				contentType: "application/json",
				data: JSON.stringify(updateData),
				success: function (data) {
					if (204 === data.status) {
						console.log("updateCanvasAppEvent Sucess");
					}
				},
			});
		}
        
		function sendCanvasAppEventLM(e) {
        	
        	//alert(e.target.id);
        	
        	let eventChannel = 'sfgbi.sendVal';
			var eventData = {
					accountId: sr.context.environment.parameters.accountId,
					loggedInUserId: sr.context.user.userId,
					accountInsightId: e.target.id,
					insightId: e.target.value
					
			};
			// Target all canvas apps.
    		Sfdc.canvas.client.publish(sr.client,{name : 'sfgbi.sendVal',payload : eventData});
    		//alert('CanvasApp Publised Canvas Event');
        	
			console.log("CanvasHerokuApp.sendCanvasAppEventLM="+ JSON.stringify(eventData));
			
		}
        
        function onComplete(){
        	
        }
        
		function onData(){
        	
        }

        Sfdc.canvas(canvasCallback);
        

    </script>
</head>
<body>
	<h1 class="slds-text-heading_medium slds-m-around_xx-small">Open Account Insights</h1>
				
	<div>
		<table class="slds-table slds-table_cell-buffer slds-table_bordered" aria-labelledby="element-with-table-label other-element-with-table-label">
		  <thead>
		    <tr class="slds-line-height_reset">
		      <th class="" scope="col">
		        <div class="slds-truncate" title="Name">Name</div>
		      </th>
		      
		      <th class="" scope="col">
		        <div class="slds-truncate" title="Id">Id</div>
		      </th>
		      <th class="" scope="col">
		        <div class="slds-truncate" title="Insight Id">Insight Id</div>
		      </th>
		      <th class="" scope="col">
		        <div class="slds-truncate" title="Javascript/Lightning Message">Javascript/Lightning Message</div>
		      </th>
		      <th class="" scope="col">
		        <div class="slds-truncate" title="Push Topic">Push Topic</div>
		      </th>
		      <th class="" scope="col">
		        <div class="slds-truncate" title="Platform Event">Platform Event</div>
		      </th>
		    </tr>
		  </thead>
	  <tbody id='insight-list'>
	    <!--<tr >
	      <td data-label="Id" scope="row">
	       <div class="slds-truncate" title="Cloudhub">Cloudhub</div>
	      </td>
	      <td data-label="Name" scope="row">
	       <div class="slds-truncate" title="Cloudhub">Cloudhub Name</div>
	      </td>
	      <td data-label="Review Tasks" scope="row">
	        <button id="button2" class="slds-button slds-button_brand" onclick="postToPlatformEvent()">Review Tasks</button>
	      </td>
	     
	    </tr> -->
	    
	  </tbody>
	</table>
	</div>
	<!--  Display context/input params -->
	<div id="wrapper" style="text-align:center" >
			<div id="container" style="display:inline-block;text-align:left" >
				<div>
					<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Application = </h1> <p id='application'></p>
			    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.User = </h1> <p id='user'></p>
			    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Environment.Dimensions with Auto Resize = </h1> <p id='dimensions'></p>
			    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Environment.Record = </h1> <p id='record'></p>
			    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Enviroment.Parameters = </h1> <p id='params'></p>
			    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">Context.Enviroment.Parameters.accountId = </h1> <p id='accountId'></p>
			    	<h1 class="slds-text-heading_large slds-m-bottom_xx-small">AccountLink</h1> <a id=accountLink href="https://www.w3schools.com" target="popup" onClick="openAccountLink()">Open AccountLink</a>
	    		</div>
	    	 	<div>
					<div class="slds-form-element">
						<div class="slds-form-element__control slds-grid slds-wrap">
							<div class="slds-col slds-size_1-of-1 slds-large-size_3-of-4">
								<input type="text" class="slds-input" placeholder="Message from Canvas App" id="post" />
							</div>
							<div class="slds-col slds-size_1-of-1 slds-large-size_1-of-4">
								<button id="button1" class="slds-button slds-button_brand" type="button" onclick="postToPlatformEvent()">Post to Platform Event</button>
							</div>
						</div>
					</div>
				</div>
		 	</div>
	</div>
	<!--  Display context/input params -->
	   
</body>
</html>
