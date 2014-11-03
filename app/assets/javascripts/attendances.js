$(document).ready(function() {
    $('#monthly-attendance-table').dataTable({
        "language": {
            "lengthMenu": 'Display <select class ="form-control" id="display-records">'+
                '<option value="50" >50</option>'+
                '<option value="100">100</option>'+
                '<option value="-1" selected>All</option>'+
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
    zohr.setMinutes(20);
    zohr.setSeconds(0);

    asor.setHours(16);
    asor.setMinutes(05);
    asor.setSeconds(00);

    magrib.setHours(17);
    magrib.setMinutes(20);
    magrib.setSeconds(0);

    if (currentTime < zohr){
        timeout = zohr - currentTime;
        var options = {
            body: "যোহরের  নামাজে যোগ দিন। ১:৩০ এ জামাত শুরু হবে।"
        };
    } else if (currentTime > zohr && currentTime < asor) {
        timeout = asor - currentTime;
        var options = {
            body: "আসরের নামাজে যোগ দিন। ৪:১৫ তে জামাত শুরু হবে।"
        };
    } else if (currentTime > asor && currentTime < magrib) {
        timeout = magrib - currentTime;
        var options = {
            body: "মাগরিবের নামাজে যোগ দিন। ৫:৩০ এ জামাত শুরু হবে।"
        };
    }

    setTimeout(function() {
        var notification = new Notification("আসসালামু আলাইকুম!", options);
    }, timeout);
}

