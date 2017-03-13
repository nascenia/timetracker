$(document).on('turbolinks:load', function() {
    $('button').click(function(){
        $op_up_down = $('#selected_employee option:selected'),
        $op_add_remove = $('#select_employee option:selected'),
        $this = $(this);

        if($op_up_down.length){
            if($this.val() == 'Up')
                $op_up_down.first().prev().before($op_up_down);
            else if($this.val() == 'Down')
                $op_up_down.last().next().after($op_up_down);
            else if($this.val() == 'Remove'){
                $op_up_down.remove();
                $op_up_down.each(function(){
                    $('#select_employee').append($('<option>', {
                        value: $(this)[0].value,
                        text : $(this)[0].text
                    }));
                });
            }
        }

        if($op_add_remove.length){
            if($this.val() == 'Add'){
                $op_add_remove.remove();
                $op_add_remove.each(function(){
                    $('#selected_employee').append($('<option>', {
                        value: $(this)[0].value,
                        text : $(this)[0].text
                    }));
                });
            }
        }
    });

    $('#create_path').click(function() {
        $user = $('#user').val();
        $chain = $("#selected_employee option").map(function() {return $(this).val();}).get();

        $.ajax({
            type: 'POST',
            url: '/approval_chains/'+ $user + '/create_chain',
            data: { chain: $chain},
            success: function(data) {
                return false;
            },
            error: function(data) {
                return false;
            }
        })
    });
});
