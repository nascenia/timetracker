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

} );
$(document).one("click", "#in", function(){

});

function notify() {
    setTimeout(function() {
        ZohrPrayerNotification();
        AsorPrayerNotification();
    }, 5000);
}
//============ Desktop Notifications for Zohr Prayer
function ZohrPrayerNotification() {
    // Let's check if the browser supports notifications
    if (!("Notification" in window)) {
        alert("This browser does not support desktop notification");
    }

    // Let's check if the user is okay to get some notification
    else if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var options = {
            body: "যোহরের  নামাজে যোগ দিন। ৫ মিনিট পর জামাত শুরু ",
            icon: "images/icon.png"
        };
        var notification = new Notification("আসসালামু আলাইকুম!", options);
    }

    // Otherwise, we need to ask the user for permission
    // Note, Chrome does not implement the permission static property
    // So we have to check for NOT 'denied' instead of 'default'
    else if (Notification.permission !== 'denied') {
        Notification.requestPermission(function (permission) {
            // Whatever the user answers, we make sure we store the information
            if (!('permission' in Notification)) {
                Notification.permission = permission;
            }

            // If the user is okay, let's create a notification
            if (permission === "granted") {
                var notification = new Notification("Hi there! 5 minutes to Zohr Prayer");
            }
        });
    }

    // At last, if the user already denied any notification, and you
    // want to be respectful there is no need to bother them any more.
}
//============ Desktop Notifications for Asor Prayer
function AsorPrayerNotification() {
    // Let's check if the user is okay to get some notification
    if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var options = {
            body: "আসরের নামাজে যোগ দিন। ৫ মিনিট পর জামাত শুরু ",
            icon: "images/icon.png"
        };
        var notification = new Notification("আসসালামু আলাইকুম!", options);
    }
}
