$(document).on('turbolinks:load', function () {

    toggle_dates();
    limit_award_dates();
    all_leaves_filters_config();

    var max_length = 300;
    $('p.help-block span').html(max_length);

    $(document).on('keyup', '#leave_reason, #comment_body', function () {
        var current_length = $('#leave_reason, #comment_body').val().length;
        var remaining_texts = max_length - current_length;
        $('p.help-block span').html(remaining_texts);
    });

    $('#leave_leave_type').on('change', function () {
        toggle_dates();
    });

    $(".navbar .dropdown-toggle").on('click', function () {
        $(this).next().toggle();
    });
    $(document).click(function () {
        $(".navbar .dropdown-menu").hide();
    });




});

function all_leaves_filters_config(){

    var date= new Date();

    var start=$('.start-date-picker-admin-filter').datepicker({
        format: 'yyyy-mm-dd',
        endDate: date,
    }).on('changeDate', function (e) {
        $(this).datepicker('hide');
        end.prop("disabled", false);
        end.datepicker('setStartDate',start.datepicker('getDate'));
    });


    var end=$('.end-date-picker-admin-filter').datepicker({
        format: 'yyyy-mm-dd',
        endDate: date,
    }).on('changeDate', function (e) {
        $(this).datepicker('hide');
        start.datepicker('setEndDate',end.datepicker('getDate'));
    });
    var timeFilter = $('#time-dropdown-filter');
    if (timeFilter.val() !== "5")
    {
        start.prop("disabled", true);
        end.prop("disabled", true);
    }

    timeFilter.change(function(){
        if ($(this).val() === "5"){
            start.prop("disabled", false);
        }
        else{
            start.val("").datepicker('update');
            end.val("").datepicker('update');
            start.prop("disabled", true);
            end.prop("disabled", true);
        }
    });


    $( "#filter-reset-btn" ).on( "click", function() {

        start.val("").datepicker('update');
        end.val("").datepicker('update');
        start.prop("disabled", true);
        end.prop("disabled", true);
        $('#time-dropdown-filter').val("");
        $('#leave-status-filter').val("");
        $('#leave-type-filter').val("");

        return false;
    });
}

function limit_award_dates() {
    $('.date-picker.award').datepicker('remove');
    var date = new Date();
    date.setDate(date.getDate());
    $('.date-picker.award').datepicker({
        format: 'yyyy-mm-dd',
        endDate: date
    }).on('changeDate', function (e) {
        $(this).datepicker('hide');
    });
}

function toggle_dates() {
    var leave_type = $('#leave_leave_type option:selected').text();
    if (leave_type == 'Casual Leave') {
        $('.date-picker').datepicker('remove');
        var date = new Date();
        date.setDate(date.getDate());
        $('.date-picker').datepicker({
            format: 'yyyy-mm-dd',
            startDate: date
        }).on('changeDate', function (e) {
            $(this).datepicker('hide');
        });
    } else if (leave_type == 'Medical Leave') {
        $('.date-picker').datepicker('remove');
        $('.date-picker').datepicker({
            format: 'yyyy-mm-dd',
        }).on('changeDate', function (e) {
            $(this).datepicker('hide');
        });
    } else {
        $('.date-picker').datepicker('remove');
        $('.date-picker').datepicker({
            format: 'yyyy-mm-dd',
        }).on('changeDate', function (e) {
            $(this).datepicker('hide');
        });
    }
}