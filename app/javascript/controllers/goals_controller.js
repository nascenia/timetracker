import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    $(document).ready(function() {
      let goal = { 
        own_id: $('#goal_user_id').val(),
        team_id: null
      };
      let year = new Date().getFullYear();
      let quaters = [
        { start_date: '01-01-', end_date: '31-03-' },
        { start_date: '01-04-', end_date: '30-06-' },
        { start_date: '01-07-', end_date: '30-09-' },
        { start_date: '01-10-', end_date: '31-12-' }
      ];
  
      //$('#goal_year').children("option:selected").val(year);
  
      $(document).on('click', 'input[type=radio]', function() {
  
        let selected = $('input[name="goal[personal_or_team]"]:checked').val();
  
        if(selected == 'own') {
          $('#goal_user_id').val(goal.own_id);
          $('select#goal_team_member').val("");
          $('#goal_team_member').prop('disabled', true);
        } else {
          $('#goal_user_id').val(goal.team_id);
          $('#goal_team_member').prop('disabled', false);
        }
      });
  
      $(document).on('change', 'select#goal_team_member', function() {
        goal.team_id = $(this).children('option:selected').val();
  
        $('#goal_user_id').val(goal.team_id);
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
  
        $('#goal_start_date').val(quaters[selectedQuater].start_date + year);
        $('#goal_end_date').val(quaters[selectedQuater].end_date + year);
      });
  
    });
  }
}