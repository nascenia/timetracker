(function( $ ) {
    //************* AUTO POPULATE OTHER FIELDS ON CHANGING ACCRUED VACATION
    $(document).on('change', '#leave_tracker_accrued_vacation_this_year', function(){
        var accruedLeave = parseInt($(this).val());
        var carriedLeave = parseInt($('#leave_tracker_carried_forward_vacation').val());
        var consumedLeave = parseInt($('#leave_tracker_consumed_vacation').val());
        var awardedLeave = parseInt($('#leave_tracker_awarded_leave').val());

        $('#leave_tracker_accrued_vacation_total').val(accruedLeave + carriedLeave);

        var balance = (accruedLeave + carriedLeave + awardedLeave) - consumedLeave;
        $('#leave_tracker_accrued_vacation_balance').val(balance);
    });

    //************* AUTO POPULATE OTHER FIELDS ON CHANGING ACCRUED MEDICAL
    $(document).on('change', '#leave_tracker_accrued_medical_this_year', function(){
        var accruedLeave = parseInt($(this).val());
        var carriedLeave = parseInt($('#leave_tracker_carried_forward_medical').val());
        var consumedLeave = parseInt($('#leave_tracker_consumed_medical').val());

        $('#leave_tracker_accrued_medical_total').val(accruedLeave + carriedLeave);

        var balance = (accruedLeave + carriedLeave ) - consumedLeave;
        $('#leave_tracker_accrued_medical_balance').val(balance);
    });

    //************* AUTO POPULATE OTHER FIELDS ON CHANGING CARRIED FORWARD VACATION
    $(document).on('change', '#leave_tracker_carried_forward_vacation', function() {
        var carriedLeave = parseInt($(this).val());
        var accruedLeave = parseInt($('#leave_tracker_accrued_vacation_this_year').val());
        var consumedLeave = parseInt($('#leave_tracker_consumed_vacation').val());
        var awardedLeave = parseInt($('#leave_tracker_awarded_leave').val());

        var balance = (accruedLeave + carriedLeave + awardedLeave) - consumedLeave;

        $('#leave_tracker_accrued_vacation_total').val(accruedLeave + carriedLeave);
        $('#leave_tracker_accrued_vacation_balance').val(balance);
    });

    //************* AUTO POPULATE OTHER FIELDS ON CHANGING CARRIED FORWARD MEDICAL
    $(document).on('change', '#leave_tracker_carried_forward_medical', function() {
        var carriedLeave = parseInt($(this).val());
        var accruedLeave = parseInt($('#leave_tracker_accrued_medical_this_year').val());
        var consumedLeave = parseInt($('#leave_tracker_consumed_medical').val());

        var balance = (accruedLeave + carriedLeave) - consumedLeave;

        $('#leave_tracker_accrued_medical_total').val(accruedLeave + carriedLeave);
        $('#leave_tracker_accrued_medical_balance').val(balance);
    });

    //************* AUTO POPULATE OTHER FIELDS ON CHANGING CONSUMED VACATION
    $(document).on('change', '#leave_tracker_consumed_vacation', function() {
        var consumedLeave = parseInt($(this).val());
        var accruedLeave = parseInt($('#leave_tracker_accrued_vacation_total').val());
        var awardedLeave = parseInt($('#leave_tracker_awarded_leave').val());

        var balance = (accruedLeave + awardedLeave) - consumedLeave;

        $('#leave_tracker_accrued_vacation_balance').val(balance);
    });

    //************* AUTO POPULATE OTHER FIELDS ON CHANGING CONSUMED MEDICAL
    $(document).on('change', '#leave_tracker_consumed_medical', function() {
        var consumedLeave = parseInt($(this).val());
        var accruedLeave = parseInt($('#leave_tracker_accrued_medical_total').val());

        var balance = accruedLeave - consumedLeave;

        $('#leave_tracker_accrued_medical_balance').val(balance);
    });
}( window.jQuery ));
