import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    $(document).ready(function() {
      var dataTable = $('#monthly-attendance-table').DataTable({
        lengthChange: false,
        pageLength: 100,
        order: [0,'asc'],
        dom: 'T<"clear">lfrtip',
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
