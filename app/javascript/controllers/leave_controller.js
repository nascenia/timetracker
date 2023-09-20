import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    $(".date-picker").datepicker({ dateFormat: 'yy-mm-dd' });
  }
}