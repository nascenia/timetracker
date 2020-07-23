$(document).ready(function() {

  var dataTable = $('#employee-info-table').DataTable({
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
  $('.dt-top-left').append($('.employee-filter-form').clone());
  if($('.employee-filter-form').length>1)
  {
    $('.employee-filter-form').hide();
    $('.employee-filter-form').eq(1).show();
  }
  $('select[name="employee_status"]').change(function(){
      $(".employee-filter-form").submit();
  });
});