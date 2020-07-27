$('#select-other-projects').hide();
$('#select-other-projects').prop('disabled',true);
$('#other-projects-cb').on('click',function () {
  if(this.checked)
  {
    $('#select-current-user-projects').hide();
    $('#select-current-user-projects').prop('disabled',true);
    $('#select-other-projects').show();
    $('#select-other-projects').prop('disabled',false);
  } else{
    $('#select-other-projects').hide();
    $('#select-other-projects').prop('disabled',true);
    $('#select-current-user-projects').show();
    $('#select-current-user-projects').prop('disabled',false);
  }
  return true;
});

function redirectToNewTimeSHeet() {

  window.location = "/timesheets/"+'new'
}

function fixedTimeSelect() {

  var date_interval = document.getElementById("time_select").value;
  var current_datetime = new Date();
  var formatted_date = current_datetime.getFullYear()+"-"+appendLeadingZeroes((current_datetime.getMonth()+ 1)) + "-"
      +appendLeadingZeroes (current_datetime.getDate());
  document.getElementById("dt2").value = formatted_date;
  var previous_datetime = new Date();
  previous_datetime.setDate( previous_datetime.getDate() - date_interval );
  var formatted_date2 = previous_datetime.getFullYear()+"-"+appendLeadingZeroes((previous_datetime.getMonth()+ 1)) + "-"
      +appendLeadingZeroes (previous_datetime.getDate());
  document.getElementById("dt1").value = formatted_date2;
  var x = document.getElementById("time_select").selectedIndex;
  var y = document.getElementById("time_select").options;
  window.location = "/timesheets/"+'?end_date='
      +document.getElementById("dt2").value
      +'&selected_index='+ y[x].index
      +'&start_date='+document.getElementById("dt1").value
}

function appendLeadingZeroes(n){
  if(n <= 9){
      return "0" + n;
  }
  return n
}

$('#dt2').datepicker({startDate: document.getElementById("dt1").value}).on('changeDate', function (ev) {
  $('#dt2').change();

  var x = document.getElementById("time_select").selectedIndex;
  var y = document.getElementById("time_select").options;
  window.location = "/timesheets/"+'?end_date='
      +document.getElementById("dt2").value
      +'&start_date='+document.getElementById("dt1").value
      +'&selected_index=0'
});

$('#dt1').datepicker().on('changeDate', function (ev) {
  $('#dt1').change();
  var x = document.getElementById("time_select").selectedIndex;
  var y = document.getElementById("time_select").options;

  window.location = "/timesheets/"+'?end_date='
      +document.getElementById("dt2").value
      +'&start_date='+document.getElementById("dt1").value
      +'&selected_index=0'
});