$(document).on('turbolinks:load', function() {

    $('.date-picker').datepicker({
        format: 'dd/mm/yyyy'
    }).on('changeDate', function(e){
        $(this).datepicker('hide');
    });

    var max_length = 300;
    $('p.help-block span').html(max_length);

    $(document).on('keyup', '#leave_reason', function() {
        var current_length = $('#leave_reason').val().length;
        var remaining_texts = max_length - current_length;
        $('p.help-block span').html(remaining_texts);
    });
});