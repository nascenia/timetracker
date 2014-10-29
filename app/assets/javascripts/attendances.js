$(document).ready(function() {
    $('#monthly-attendance-table').dataTable({
        "language": {
            "lengthMenu": 'Display <select class ="form-control">'+
                '<option value="50">50</option>'+
                '<option value="75">75</option>'+
                '<option value="100">100</option>'+
                '<option value="-1">All</option>'+
                '</select> records'
        },
        dom: 'T<"clear">lfrtip',
        tableTools: {
            "sSwfPath": "http://cdn.datatables.net/tabletools/2.2.2/swf/copy_csv_xls_pdf.swf",
            "aButtons": [ "csv", "xls", "pdf", "print" ]
        }

    });

    //============ Disabling button
    var entry = $('#todays_entry').val();
    if (entry){
        $("#in").attr("disabled", "disabled");
    } else {
        $("#out").attr("disabled", "disabled");
    }
    notify();
} );

function notify() {
    var currentTime = new Date(), zohr = new Date(), asor = new Date(), magrib = new Date();

    zohr.setHours(13);
    zohr.setMinutes(25);
    zohr.setSeconds(0);

    asor.setHours(16);
    asor.setMinutes(15);
    asor.setSeconds(0);

    magrib.setHours(17);
    magrib.setMinutes(25);
    magrib.setSeconds(0);

    if (currentTime < zohr){
        timeout = zohr - currentTime;
        setTimeout(function() {
            ZohrPrayerNotification();
        }, timeout);
    } else if (currentTime > zohr && currentTime < asor) {
        timeout = asor - currentTime;
        setTimeout(function() {
            AsorPrayerNotification();
        }, timeout);
    } else if (currentTime > asor && currentTime < magrib) {
        timeout = magrib - currentTime;
        setTimeout(function() {
            MagribPrayerNotification();
        }, timeout);
    }
}
//============ Desktop Notifications for Zohr Prayer
function ZohrPrayerNotification() {
    if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var options = {
            body: "যোহরের  নামাজে যোগ দিন। ১:৩০ এ জামাত শুরু হবে।"
        };
        var notification = new Notification("আসসালামু আলাইকুম!", options);
        notify();
    }
}
//============ Desktop Notifications for Asor Prayer
function AsorPrayerNotification() {
    if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var options = {
            body: "আসরের নামাজে যোগ দিন। ৪:১৫ তে জামাত শুরু হবে।"
        };
        var notification = new Notification("আসসালামু আলাইকুম!", options);
        notify();
    }
}
//============ Desktop Notifications for Magrib Prayer
function MagribPrayerNotification() {
    if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var options = {
            body: "মাগরিবের নামাজে যোগ দিন। ৫:৩০ এ জামাত শুরু হবে।"
        };
        var notification = new Notification("আসসালামু আলাইকুম!", options);
        notify();
    }
}
