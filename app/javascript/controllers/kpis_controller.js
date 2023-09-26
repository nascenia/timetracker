import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    $(document).ready(function() {
      let kpi = { 
        own_id: $('#kpi_user_id').val(),
        team_id: null
      };
      let year = new Date().getFullYear();
      let quaters = [
        { start_date: '01-01-', end_date: '31-03-' },
        { start_date: '01-04-', end_date: '30-06-' },
        { start_date: '01-07-', end_date: '30-09-' },
        { start_date: '01-10-', end_date: '31-12-' }
      ];
  
      //$('#kpi_year').children("option:selected").val(year);
  
      $(document).on('click', 'input[type=radio]', function() {
  
        let selected = $('input[name="kpi[personal_or_team]"]:checked').val();
  
        if(selected == 'own') {
          $('#kpi_user_id').val(kpi.own_id);
          $('select#kpi_team_member').val("");
          $('#kpi_team_member').prop('disabled', true);
        } else {
          $('#kpi_user_id').val(kpi.team_id);
          $('#kpi_team_member').prop('disabled', false);
        }
      });
  
      $(document).on('change', 'select#kpi_team_member', function() {
        kpi.team_id = $(this).children('option:selected').val();
  
        $('#kpi_user_id').val(kpi.team_id);
      });
  
      $(document).on('change', 'select#kpi_year', function() {
        year = $(this).children("option:selected").val();
  
        let start_date = $('#kpi_start_date').val();
        let end_date = $('#kpi_end_date').val();
  
        if(start_date != '') {
          let tokens = start_date.split('-');
          $('#kpi_start_date').val(tokens[0] + '-' + tokens[1] + '-' + year);
        }
  
        if(end_date != '') {
          let tokens = end_date.split('-');
          $('#kpi_end_date').val(tokens[0] + '-' + tokens[1] + '-' + year);
        }
      });
  
      $(document).on('change', 'select#kpi_time_period', function() {
        let selectedQuater = $(this).children("option:selected").val();
  
        $('#kpi_start_date').val(quaters[selectedQuater].start_date + year);
        $('#kpi_end_date').val(quaters[selectedQuater].end_date + year);
      });
  
    });
  }
}
