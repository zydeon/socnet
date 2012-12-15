function checkfields(){ 
	if(document.getElementById('user').value=='' || document.getElementById('user').value==null){
		alert("Invalid Username");
		document.getElementById('user').focus();
		return false; 
	}
	
	if(document.getElementById('password').value=='' || document.getElementById('password').value==null){
		alert("Invalid Password");
		document.getElementById('password').focus();
		return false; 
	}
	
	if(document.getElementById('password').value != document.getElementById('cpassword').value) { 
		alert("Your Passwords do not match.");
		document.getElementById('password').focus();
		return false; 
	}obj.option[obj.selectedIndex]
	
}

function daysInMonth(month,year) {
	var dd = new Date(year, month, 0);
	return dd.getDate();
}

function setDayDrop(dyear, dmonth, dday) {
	var year = dyear.options[dyear.selectedIndex].value;
	var month = dmonth.options[dmonth.selectedIndex].value;
	var day = dday.options[dday.selectedIndex].value;
	var days = (year == ' ' || month == ' ') ? 31 : daysInMonth(month,year);
	dday.options.length = 0;
	dday.options[dday.options.length] = new Option('Day',' ');
	for (var i = 1; i <= days; i++)
		dday.options[dday.options.length] = new Option(i,i);
}

function setDay() {
	var year = document.getElementById('year');
	var month = document.getElementById('month');
	var day = document.getElementById('day');
	setDayDrop(year,month,day);
}

function toggleCity(){
	var list_country = document.getElementById('country');

	console.log(list_country);

	if(list_country.options[list_country.selectedIndex].value=='none'){
		document.getElementById('city').style.display='inline';
		document.getElementById('city').style.visibility='hidden';
	}
	else{
		document.getElementById('city').style.display='inline';
		document.getElementById('city').style.visibility='visible';			
	}
}