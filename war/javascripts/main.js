var map;
var xmlHttpReq = null;
var selectedMarkerID;
var guestbookNameString = "";

function loadMarkers() {
	//alert("loadMarkers");
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_loadMarkers;
		var url = "/resources/markers.xml";
	
		xmlHttpReq.open('GET', url, true);
    	xmlHttpReq.send(null);
    	
    	//alert();
    	
	} catch (e) {
    	alert("Error: " + e);
	}	
}

function httpCallBackFunction_loadMarkers() {
	//alert("httpCallBackFunction_loadMarkers");
	
	if (xmlHttpReq.readyState == 1){
		//updateStatusMessage("<blink>Opening HTTP...</blink>");
	}else if (xmlHttpReq.readyState == 2){
		//updateStatusMessage("<blink>Sending query...</blink>");
	}else if (xmlHttpReq.readyState == 3){ 
		//updateStatusMessage("<blink>Receiving...</blink>");
	}else if (xmlHttpReq.readyState == 4){
		var xmlDoc = null;

		if(xmlHttpReq.responseXML){
			xmlDoc = xmlHttpReq.responseXML;
		}else if(xmlHttpReq.responseText){
			var parser = new DOMParser();
		 	xmlDoc = parser.parseFromString(xmlHttpReq.responseText,"text/xml");			 	
		}

		if(xmlDoc){				
			//alert(xmlHttpReq.responseText);	
						
			var markerElements = xmlDoc.getElementsByTagName('marker');
			//alert(markerElements[0].getAttribute("srl"));	
			//alert(markerElements.length);
			
			for(mE = 0; mE < markerElements.length; mE++) {
				var markerElement = markerElements[mE];
				
				//alert(markerElement.getAttribute("srl"));
				
				var lat = parseFloat(markerElement.getAttribute("lat"));
				var lng = parseFloat(markerElement.getAttribute("lng"));
				var srl = markerElement.getAttribute("srl");
							
				var myLatlng = new google.maps.LatLng(lat, lng);
								
				var mrkID = ""+srl;
				var msgbox = "msgbox_"+mrkID;				
				var msglist = "msglist_"+mrkID;
				var gstBkNm = guestbookNameString; // "default"; 
				
				var day = "<select name='day' id='day"+mrkID+"'>";
				var month = "<select name='month' id='month"+mrkID+"'>";
				var year = "<select name='year' id='year"+mrkID+"'>";
				
				for(var i = 0; i <= 30; i++){
					day += "<option value="+(i+1)+">";
					day += (i+1)+ "</option>";
				}
				day += "</select>";
				
				var months = ["January", "Febuary", "March", "April", "May", "June", "July",
				              "August", "September", "October", "November", "December"];
				
				for(var i = 0; i < months.length; i++){
					month += "<option value="+(i)+">";
					month += months[i]+ "</option>";
				}
				month += "</select>";
				var currentYear = new Date().getFullYear();
				for(var i = currentYear; i <= (currentYear + 4); i++){
					year += "<option value="+ i+">"+i+"</option>";
				}
				year += "</select>";
				
				var amountOfHours = "<select name='hours' id='amount"+mrkID+"'>";
				for(var i = 0; i < 24; i++){
					amountOfHours += "<option value="+(i+1)+">";
					amountOfHours += (i+1)+ "</option>";
				}
				amountOfHours += "</select>";
				var contentString  = 'Parking ' + mrkID + '</div><div>' + 
				'<label for="month'+mrkID+'">Month</label>'+month+"<br/>"+
				'<label for="day'+mrkID+'">Day</label>'+day+"<br/>"+
				'<label for="year'+mrkID+'">Year</label>'+year+"<br/>"+
				'<label for="amount'+mrkID+'">Amount of Hours</label>'+amountOfHours+"<br/>"+
				  '<textarea id="'+ msgbox +'" rows="2" cols="20"></textarea>' +'<br/>'+			  
				  '<input type="button" value="Reserve" onclick="postAjaxRequest('+ 
					"'" + msgbox + "', '" + mrkID + "', '"+lat+"', '"+lng+"', '"+ gstBkNm + "', '" + msglist + "'" +')"/></div>'; 
				
				var iconBase = 'https://maps.google.com/mapfiles/kml/shapes/';
				var icons = {
	  				parking: {
	    				icon: iconBase + 'parking_lot_maps.png'
	  				},
	  				library: {
	    				icon: iconBase + 'library_maps.png'
	  				},
	  				info: {
	    				icon: iconBase + 'info-i_maps.png'
	  				}
				};
														
				var marker = new google.maps.Marker({       
					position: myLatlng,
					map: map,
					icon: icons['parking'].icon,
					title: 'Parking '+mrkID
				});
								
				addInfowindow(marker, contentString);
			}			
		}else{
			alert("No data.");
		}	
	}		
}

function addInfowindow(marker, content) {
	var infowindow = new google.maps.InfoWindow({
			content: content
	});
	google.maps.event.addListener(marker, 'click', function() {
		selectedMarkerID = marker.getTitle();
		infowindow.setContent(""+content);
		infowindow.setPosition(marker.getPosition());
		infowindow.open(marker.get('map'), marker);		 
		getAjaxRequest(); 
	});
}

function getAjaxRequest() {
	//alert("getAjaxRequest");
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_getAjaxRequest;
		var url = "/queryprocessor/?markerID="+selectedMarkerID+"&guestbookName="+guestbookNameString;
		
		xmlHttpReq.open('GET', url, true);
    	xmlHttpReq.send(null);
    	
    	//alert();
    	
	} catch (e) {
    	alert("Error: " + e);
	}	
}

function httpCallBackFunction_getAjaxRequest() {
	//alert("httpCallBackFunction_getAjaxRequest");
	
	if (xmlHttpReq.readyState == 1){
		//updateStatusMessage("<blink>Opening HTTP...</blink>");
	}else if (xmlHttpReq.readyState == 2){
		//updateStatusMessage("<blink>Sending query...</blink>");
	}else if (xmlHttpReq.readyState == 3){ 
		//updateStatusMessage("<blink>Receiving...</blink>");
	}else if (xmlHttpReq.readyState == 4){
		var xmlDoc = null;

		if(xmlHttpReq.responseXML){
			xmlDoc = xmlHttpReq.responseXML;
		}else if(xmlHttpReq.responseText){
			var parser = new DOMParser();
		 	xmlDoc = parser.parseFromString(xmlHttpReq.responseText,"text/xml");			 	
		}

		if(xmlDoc){				
			//alert(xmlHttpReq.responseText);			
			document.getElementById("msglist_"+selectedMarkerID).innerHTML=xmlHttpReq.responseText;					
		}else{
			alert("No data.");
		}	
	}		
}

function postAjaxRequest(postMsg, markerID, latitude, longitude, guestbookName,rspMsgList) {
	//alert("postAjaxRequest");
	var day = document.getElementById("day"+markerID).options[document.getElementById("day"+markerID).selectedIndex].value;
	var month = document.getElementById("month"+markerID).options[document.getElementById("month"+markerID).selectedIndex].value;
	var year = document.getElementById("year"+markerID).options[document.getElementById("year"+markerID).selectedIndex].value;
	var chosenDate = new Date();
	var now = new Date();
	chosenDate.setFullYear(year, month, day);
	if (chosenDate < new Date()){
		alert("Selected date must be in the future");
	}
	else {
		try {
			xmlHttpReq = new XMLHttpRequest();
			xmlHttpReq.onreadystatechange = httpCallBackFunction_postAjaxRequest;
			var url = "/sign_in";
			xmlHttpReq.open("POST", url, true);
			xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');		
			
			var postMsgValue = document.getElementById(postMsg).value;
			var markerIDValue = markerID; 
			var guestbookNameValue = guestbookName; 
	    	
			xmlHttpReq.send("content="+postMsgValue+"&markerID="+markerIDValue+"&guestbookName="+guestbookNameValue+
							"&userLatitude="+latitude+"&userLongitude="+longitude+"&measureAccuracy=2");
	    	
	    	//alert();
	    	
		} catch (e) {
	    	alert("Error: " + e);
		}
	}
}

function httpCallBackFunction_postAjaxRequest() {
	//alert("httpCallBackFunction_postAjaxRequest");
	
	if (xmlHttpReq.readyState == 1){
		//updateStatusMessage("<blink>Opening HTTP...</blink>");
	}else if (xmlHttpReq.readyState == 2){
		//updateStatusMessage("<blink>Sending query...</blink>");
	}else if (xmlHttpReq.readyState == 3){ 
		//updateStatusMessage("<blink>Receiving...</blink>");
	}else if (xmlHttpReq.readyState == 4){
		var xmlDoc = null;

		if(xmlHttpReq.responseXML){
			xmlDoc = xmlHttpReq.responseXML;			
		}else if(xmlHttpReq.responseText){
			var parser = new DOMParser();
		 	xmlDoc = parser.parseFromString(xmlHttpReq.responseText,"text/xml");		 		
		}
		
		if(xmlDoc){				
			alert("Greeting Posted.");
		}else{
			alert("No data.");
		}	
	}		
}