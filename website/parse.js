
// 
// BudGet v1.0.3
// (c) Aditya Kumar, 2023
// Some rights reserved.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// 
// This code is NOT intended to work on any systems apart from mine,
// so do NOT expect active support from me.
// 
// Do NOT redistribute this program without first consulting with
// the original developer, i.e. me.
// 

var mydata = JSON.parse(data);
var myprefs = JSON.parse(prefs);
const advisableMonthlySpendings = Number(myprefs.advmonthly);

document.getElementById("monthTarget").innerHTML = String(
  advisableMonthlySpendings.toFixed(2)
);
if (myprefs.webbg != "none") {
  document.getElementById("mainbody").style.backgroundImage =
    "url('bg/" + myprefs.webbg + "')";
}

const months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];
// English weekdays:
const days = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
];
// Japanese weekdays:
//const days = ["日", "月", "火", "水", "木", "金", "土"];

function leadingZeroes(num) {
  //hard-coded logic
  if (num == 0) return "00";
  if (num < 10) return "0" + num;
  return String(num);
}
function getFormattedDate(date) {
  return (
    String(date.getDate()) +
    "/" +
    Number(date.getMonth() + 1) +
    "/" +
    date.getFullYear() +
    " at " +
    leadingZeroes(date.getHours()) +
    ":" +
    leadingZeroes(date.getMinutes()) +
    ":" +
    leadingZeroes(date.getSeconds())
  );
}

var total = 0;
var month = 0;
var yeartotal = 0;

const d = new Date();
const monthDate = new Date(d.getFullYear(), d.getMonth());
const yearDate = new Date(d.getFullYear());

for (iter in mydata) {
  total += Number(mydata[iter].Amount);
  const publishDate = new Date(Number(mydata[iter].Date) * 1000);

  //console.log(publishDate);

  if (publishDate >= monthDate) {
    month += Number(mydata[iter].Amount);
  }

  if (publishDate >= yearDate) {
    yeartotal += Number(mydata[iter].Amount);
  }
}

document.getElementById("month").innerHTML = months[d.getMonth()];
//document.getElementById("expense").innerHTML = total.toFixed(2);
document.getElementById("month-expense").innerHTML = month.toFixed(2);
document.getElementById("yearspend").innerHTML = yeartotal.toFixed(2);

function daysInMonth(year, month) {
  return new Date(year, month + 1, 0).getDate();
}

const calendar = [];
for (var i = 0; i < monthDate.getDay(); i++) {
  calendar[i] = { Invalid: 1 };
}

for (
  var i = monthDate.getDay();
  i <
  monthDate.getDay() +
    daysInMonth(monthDate.getFullYear(), monthDate.getMonth());
  i++
) {
  calendar[i] = { Invalid: 0 };
  calendar[i].Date = i - monthDate.getDay() + 1;
  calendar[i].Amount = Number(0);
  calendar[i].Payments = Number(0);
}

if (calendar.length % 7 > 0) {
  var remaining = 7 - (calendar.length % 7);
  //console.log("Days to fill: "+remaining);
  for (var i = 0; i < remaining; i++) {
    calendar[
      i +
        (monthDate.getDay() +
          daysInMonth(monthDate.getFullYear(), monthDate.getMonth()))
    ] = { Invalid: 1 };
    //console.log("emty niga " + (1+i+(monthDate.getDay()+daysInMonth(monthDate.getFullYear(), monthDate.getMonth()))));
  }
}

for (iter in mydata) {
  const publishDate = new Date(Number(mydata[iter].Date) * 1000);
  if (publishDate >= monthDate) {
    calendar[publishDate.getDate() + monthDate.getDay() - 1].Amount += Number(
      mydata[iter].Amount
    );
    calendar[publishDate.getDate() + monthDate.getDay() - 1].Payments++;
    console.log(
      "Date " +
        (publishDate.getDate() + monthDate.getDay() - 1) +
        ": " +
        Number(mydata[iter].Amount)
    );
  }
}

//console.log("Calen length: "+calendar.length);

const remainingDailyLimit =
  (advisableMonthlySpendings -
    (month - calendar[d.getDate() + monthDate.getDay() - 1].Amount)) /
  (daysInMonth(monthDate.getFullYear(), monthDate.getMonth()) -
    d.getDate() +
    1);
const currentWeek = Math.round((d.getDate() + monthDate.getDay()) / 7 - 0.51);

document.getElementById("dailyTarget").innerHTML =
  remainingDailyLimit.toFixed(2);

const dailySpendRate =
  (month - calendar[d.getDate() + monthDate.getDay() - 1].Amount) /
  (d.getDate() - 1);
const zeroBalEstimate = new Date(monthDate);
zeroBalEstimate.setDate(
  zeroBalEstimate.getDate() + advisableMonthlySpendings / dailySpendRate
);
const nextMonth = new Date(monthDate);
nextMonth.setDate(
  nextMonth.getDate() +
    daysInMonth(monthDate.getFullYear(), monthDate.getMonth())
);

if (zeroBalEstimate < nextMonth) {
  var caution =
    '<br><span style="color:ff8080">CAUTION: You are set to run out of money by ';
  caution += zeroBalEstimate.getDate() + " ";
  caution += months[zeroBalEstimate.getMonth()] + " ";
  caution += zeroBalEstimate.getFullYear();
  caution += "</span>";
  document.getElementById("caution").innerHTML = caution;
  document.getElementsByClassName("head-stats")[0].style.backgroundColor =
    "rgba(255,125,125,0.2)";
}

var calentable = "<table><tr>";
for (var i = 0; i < 7; i++) {
  calentable += "<div style=\"content=''\"><td";
  if (i == 0 || i == 6) {
    calentable += ' bgcolor="#ff8080"';
  } else {
    calentable += ' bgcolor="#b0b0b0"';
  }
  calentable +=
    '><center style="font-size:17px">' + days[i] + "</center></td></div>";
}
calentable +=
  '<td bgcolor="#8080ff"><center style="font-size:17px">Weekly Total</center></td>';
calentable += "</tr>";
for (var i = 0; i < calendar.length / 7; i++) {
  calentable += "<tr>";
  var weekTotal = 0;
  var weekLimit = 0;
  for (var j = 0; j < 7; j++) {
    calentable += '<td class="calentd"';
    /*                    if (!calendar[i*7+j].Invalid && 
            calendar[i*7+j].Amount > (advisableMonthlySpendings / daysInMonth(monthDate.getFullYear(), monthDate.getMonth()))) {
            //calentable += " style=\"background: repeating-linear-gradient(-45deg, #ffb3b3, #ffb3b3 10px, #ffff1a 1px, #ffff1a 12px);\"";
            calentable += " style=\"font-color: #ffffa1\"";
        }*/
    if (calendar[i * 7 + j].Date == d.getDate()) {
      calentable += ' bgcolor="#b3ffb3"';
    } else if (j == 0 || j == 6) {
      calentable += ' bgcolor="#ffb3b3"';
    } else {
      calentable += ' bgcolor="#ffffff"';
    }
    calentable += ' width="12%"><center>';
    if (!calendar[i * 7 + j].Invalid) {
      calentable += '<span style="font-size:15px">';
      calentable += String(calendar[i * 7 + j].Date);
      calentable += "</span><br>&#8377;";
      //                        if (calendar[i*7+j].Amount > (advisableMonthlySpendings / daysInMonth(monthDate.getFullYear(), monthDate.getMonth()))) {
      if (calendar[i * 7 + j].Amount > remainingDailyLimit) {
        calentable +=
          '<span style="color: #e05252">' +
          String(calendar[i * 7 + j].Amount.toFixed(2)) +
          "</span>";
      } else {
        calentable += String(calendar[i * 7 + j].Amount.toFixed(2));
      }
      weekTotal += calendar[i * 7 + j].Amount;
      /*                        if (((i*7+j)-monthDate.getDay()) >= d.getDate()-1) weekLimit += remainingDailyLimit;
            else if (i == currentWeek) weekLimit += calendar[i*7+j].Amount;
            else weekLimit += advisableMonthlySpendings / daysInMonth(monthDate.getFullYear(), monthDate.getMonth())*/
      if (i >= currentWeek) weekLimit += remainingDailyLimit;
      else
        weekLimit +=
          advisableMonthlySpendings /
          daysInMonth(monthDate.getFullYear(), monthDate.getMonth());
    }
    calentable += "</center>";
    if (!calendar[i * 7 + j].Invalid && calendar[i * 7 + j].Amount != 0) {
      calentable +=
        '<span class="calentdtt">Average: ' +
        String(
          (calendar[i * 7 + j].Amount / calendar[i * 7 + j].Payments).toFixed(2)
        ) +
        "<br>Payments: " +
        String(calendar[i * 7 + j].Payments) +
        "</span>";
    } else {
      calentable += '<span class="calentdtt">No data.</span>';
    }
    calentable += "</td>";
  }
  calentable += '<td bgcolor="#b3b3ff">&#8377;';
  if (weekTotal > weekLimit) {
    calentable +=
      '<span style="color: #e05252">' + String(weekTotal.toFixed(2));
    if (i == currentWeek) {
      calentable += "/" + String(weekLimit.toFixed(2));
    }
    calentable += "</span>";
  } else {
    calentable += "<span>" + String(weekTotal.toFixed(2));
    if (i == currentWeek) {
      calentable += "/" + String(weekLimit.toFixed(2));
    }
    calentable += "</span>";
  }
  calentable += "</td></tr>";
  console.log(weekLimit);
}
calentable += "</table>";

document.getElementById("calendar").innerHTML = calentable;

var keys = ["Expense", "Date", "Amount"];
var table = "";
var month = "";
var monthSummary = "";

var monthTotal = 0;
var monthTransactions = 0;

function isDiffMonth(s1, s2) {
  const d1 = new Date(Number(s1) * 1000);
  const d2 = new Date(Number(s2) * 1000);

  if (d1.getMonth() != d2.getMonth()) {
    console.log(d1.getMonth());
    return true;
  }
  return false;
}

for (var i = mydata.length - 1; i >= 0; i--) {
  if (mydata[i].Expense == "Placeholder") {
    continue;
  }
  const d = new Date(Number(mydata[i].Date) * 1000);
  if (
    i != mydata.length - 1 &&
    isDiffMonth(mydata[i].Date, mydata[i + 1].Date)
  ) {
    var monthSummary =
      '<div style="font-size: 25px">Spent this month: &#8377;' +
      monthTotal.toFixed(2) +
      "<br>Payments: " +
      monthTransactions +
      "<br>";
    month = monthSummary + month;
    monthTotal = 0;
    monthTransactions = 0;
    table += month + "</table></div></div>";
    table +=
      '<div><button type="button" class="collapse" style="font-size: 28px"><span style="font-size: 15px; vertical-align: middle;">&#9660;</span> ' +
      months[d.getMonth()] +
      " " +
      String(d.getFullYear()) +
      '</button><div class="monthexp">';
    month = "<table><tr>";
    for (key in keys) {
      month += "<td>" + keys[key] + "</td>";
    }
    month += "</tr><tr>";
  } else if (i == mydata.length - 1) {
    table +=
      '<div><button type="button" class="collapse" style="font-size: 28px"><span style="font-size: 15px; vertical-align: middle;">&#9660;</span> ' +
      months[d.getMonth()] +
      " " +
      String(d.getFullYear()) +
      '</button><div class="monthexp">';
    month = "<table><tr>";
    for (key in keys) {
      month += "<td>" + keys[key] + "</td>";
    }
    month += "</tr><tr>";
  } else {
    month += "<tr>";
  }
  for (key in keys) {
    switch (Number(key)) {
      case 0:
        month += "<td>" + mydata[i].Expense + "</td>";
        break;
      case 1:
        month += "<td>" + getFormattedDate(d) + "</td>";
        break;
      case 2:
        month += "<td>&#8377;" + Number(mydata[i].Amount) + "</td>";
        break;
      default:
        month += "<td>? [" + key + "]</td>";
    }
  }
  month += "</tr>";
  monthTotal += Number(mydata[i].Amount);
  monthTransactions++;
}
month =
  '<div style="font-size: 25px">Spent this month: &#8377;' +
  monthTotal.toFixed(2) +
  "<br>Payments: " +
  monthTransactions +
  "<br>" +
  month;
table += month;
table += "</table></div>";

document.getElementById("tablehere").innerHTML = table;

startListen();
