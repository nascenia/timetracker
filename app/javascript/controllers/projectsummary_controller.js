import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    $(document).ready(function() {
      $(".date-picker").datepicker();
      
      $(document).on('change', 'select#project_time_period', function() {

        let time_period = $(this).children("option:selected").val();
        let date = new Date();
        
        date.setDate(date.getDate() - time_period);
        let month = (date.getMonth() + 1) <= 9 ? "0" + (date.getMonth() + 1) : (date.getMonth() + 1);
        
        $('#project_start_date').val(date.getFullYear() + "/" + month + "/" + date.getDate());
      });
      
      var dataTable = $('#projects-summary').DataTable({
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
    });
  }
}
