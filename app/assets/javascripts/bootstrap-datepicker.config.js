$(document).on('turbolinks:load', function() {

    toggle_dates();

    var max_length = 300;
    $('p.help-block span').html(max_length);

    $(document).on('keyup', '#leave_reason, #comment_body', function() {
        var current_length = $('#leave_reason, #comment_body').val().length;
        var remaining_texts = max_length - current_length;
        $('p.help-block span').html(remaining_texts);
    });

    $('#leave_leave_type').on('change', function () {
        toggle_dates();
    });

});

function toggle_dates(){
    var leave_type = $('#leave_leave_type option:selected').text();
    if( leave_type == 'Casual Leave'){
        $('.date-picker').datepicker('remove');
        var date = new Date();
        date.setDate(date.getDate() + 1 );
        $('.date-picker').datepicker({
            format: 'dd/mm/yyyy',
            startDate: date
        }).on('changeDate', function(e){
            $(this).datepicker('hide');
        });
    }
    else if( leave_type == 'Medical Leave' ){
        $('.date-picker').datepicker('remove');
        $('.date-picker').datepicker({
            format: 'dd/mm/yyyy'
        }).on('changeDate', function(e){
            $(this).datepicker('hide');
        });
    }
    else{
        $('.date-picker').datepicker('remove');
        $('.date-picker').datepicker({
            format: 'dd/mm/yyyy'
        }).on('changeDate', function(e){
            $(this).datepicker('hide');
        });
    }
}