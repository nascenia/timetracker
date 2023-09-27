import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    $(document).ready(function() {
      $(".date-picker").datepicker({ dateFormat: 'yy-mm-dd' });

      $('#select-other-projects').hide();
      $('#select-other-projects').prop('disabled', true);

      $(document).on('click', '#other-projects-cb', function (e) {
        if(this.checked) {
          $('select#select-current-user-projects').hide();
          $('select#select-current-user-projects').prop('disabled', true);
          $('select#select-other-projects').show();
          $('select#select-other-projects').prop('disabled', false);
        } else {
          $('select#select-other-projects').hide();
          $('select#select-other-projects').prop('disabled', true);
          $('select#select-current-user-projects').show();
          $('select#select-current-user-projects').prop('disabled', false);
        }
      });
    });
  }
}
