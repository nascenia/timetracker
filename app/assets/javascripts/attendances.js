$(document).ready(function() {
    $('#monthly-attendance-table').dataTable({
        "iDisplayLength": 50,
        dom: 'T<"clear">lfrtip',
        tableTools: {
            "sSwfPath": "http://cdn.datatables.net/tabletools/2.2.2/swf/copy_csv_xls_pdf.swf",
            "aButtons": ["pdf", "print" ]
        }

    });
    //============ Disabling IN/Out button =======
    var entry = $('#todays_entry').val();
    if (entry){
        $("#in").attr("disabled", "disabled");
    } else {
        $("#out").attr("disabled", "disabled");
    }

    //=========== Setting Desktop Notification ====
    notify();
} );

function notify() {
    var currentTime = new Date(), zohr = new Date(), asor = new Date(), magrib = new Date();

    zohr.setHours(13);
    zohr.setMinutes(20);
    zohr.setSeconds(0);

    asor.setHours(16);
    asor.setMinutes(05);
    asor.setSeconds(00);

    magrib.setHours(17);
    magrib.setMinutes(20);
    magrib.setSeconds(0);

    if (currentTime < zohr){
         var timeout = zohr - currentTime;
        var options = {
            body: "যোহরের  নামাজে যোগ দিন। ১:৩০ এ জামাত শুরু হবে।"
        };
    } else if (currentTime > zohr && currentTime < asor) {
        var timeout = asor - currentTime;
        var options = {
            body: "আসরের নামাজে যোগ দিন। ৪:১৫ তে জামাত শুরু হবে।"
        };
    } else if (currentTime > asor && currentTime < magrib) {
        var timeout = magrib - currentTime;
        var options = {
            body: "মাগরিবের নামাজে যোগ দিন। ৫:৩০ এ জামাত শুরু হবে।"
        };
    }
    if (currentTime < magrib ){
        setTimeout(function() {
            var notification = new Notification("আসসালামু আলাইকুম!", options);
        }, timeout);
    }

    setTimeout(function() {
        location.reload();
    }, 60000);
}

