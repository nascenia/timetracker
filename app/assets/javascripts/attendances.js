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

} );
