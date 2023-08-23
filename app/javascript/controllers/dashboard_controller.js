import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log(this.element);
    $("#datepicker").datepicker();
    console.log($.ui);

    $(document).on('click', '.monthly-summary', function() {
      var user = {
        id: $(this).data().userId,
        month: $(this).data().userMonth,
        year: $(this).data().userYear
      };
  
      $.ajax({
        url: "/attendances/monthly_summary",
        type: "GET",
        data:  { user: user },
        beforeSend: function() {
          $("#modal-loading-image").show();
        },
        success: function(msg) {
          $("#modal-loading-image").hide();
        }
      });
    });
  
    $(document).on('click', '#rules', function() {
      $("#rulesModal").modal('show');
    });
  }
}