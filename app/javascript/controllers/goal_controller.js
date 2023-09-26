import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    $(document).ready(function() {
      let goal = { 
        own: $('#goal_user_id').val(),
        team: null
      };
      let year = new Date().getFullYear();
      let quaters = [
        { start_date: '01-01-' + year, end_date: '31-03-' + year },
        { start_date: '01-04-' + year, end_date: '30-06-' + year },
        { start_date: '01-07-' + year, end_date: '30-09-' + year },
        { start_date: '01-10-' + year, end_date: '31-12-' + year }
      ];
  
      $(document).on('click', 'input[type=radio]', function() {
  
        let selected = $('input[name="goal[personal_or_team]"]:checked').val();
  
        if(selected == 'own') {
          $('#goal_team_member').prop('disabled', 'disabled');
        } else {
          $('#goal_team_member').prop('disabled', '');
        }
      });
  
      $(document).on('change', 'select#goal_team_member', function() {
        goal.team = $(this).children('option:selected').val();
  
        $('#goal_user_id').val(goal.team);
      });
  
      $(document).on('change', 'select#goal_year', function() {
        year = $(this).children("option:selected").val();
  
        let start_date = $('#goal_start_date').val();
        let end_date = $('#goal_end_date').val();
  
        if(start_date != '') {
          let tokens = start_date.split('-');
          $('#goal_start_date').val(tokens[0] + '-' + tokens[1] + '-' + year);
        }
  
        if(end_date != '') {
          let tokens = end_date.split('-');
          $('#goal_end_date').val(tokens[0] + '-' + tokens[1] + '-' + year);
        }
      });
      
      $(document).on('change', 'select#goal_time_period', function() {
        let selectedQuater = $(this).children("option:selected").val();
  
        $('#goal_start_date').val(quaters[selectedQuater].start_date);
        $('#goal_end_date').val(quaters[selectedQuater].end_date);
      });
  
    });
  }
}