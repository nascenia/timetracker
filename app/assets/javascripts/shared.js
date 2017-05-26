function change_leave_type(leave) {
    type = $('#leave_type').find(":selected").text();

    $.ajax({
        url: '/super_admin_leaves/' + leave + '/change_type',
        type: 'PATCH',
        data: { type: type }
    });
}
