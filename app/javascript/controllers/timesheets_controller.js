import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    $(document).ready(function() {
      $(".date-picker").datepicker({ dateFormat: 'yy-mm-dd' });

      $(document).on('change', 'select#timesheet_time_period', function() {

        let time_period = $(this).children("option:selected").val();
        let date = new Date();
        
        date.setDate(date.getDate() - time_period);
        let month = (date.getMonth() + 1) <= 9 ? "0" + (date.getMonth() + 1) : (date.getMonth() + 1);
        
        $('#timesheet_start_date').val(date.getFullYear() + "-" + month + "-" + date.getDate());
      });

    });
  }
}
