$(document).ready(function() {
    var dataTable = $('#employee-info-table').DataTable({
        lengthChange: false,
        pageLength: 100,
        dom: '<"dt-top-left"Tf>lrtip',
        buttons: ['print']
    });
    $(document).on("turbolinks:before-cache", function() {
        if (dataTable !== null) {
            dataTable.destroy();
            dataTable = null;
        }
    });
    $('.dt-top-left').append($('#filter-form'));
    $('select[name="employee_status"]').change(function(){
        $("#filter-form").submit();
        console.log("helo");
    });
});