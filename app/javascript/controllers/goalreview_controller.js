import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    $(document).ready(function() {
      let goal = { 
        team: $('#goal_user_id').val()
      };
      let year = new Date().getFullYear();
      let quaters = [
        { start_date: '01-01-', end_date: '31-03-' },
        { start_date: '01-04-', end_date: '30-06-' },
        { start_date: '01-07-', end_date: '30-09-' },
        { start_date: '01-10-', end_date: '31-12-' }
      ];
  
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
  
        $('#goal_start_date').val(quaters[selectedQuater].start_date + year);
        $('#goal_end_date').val(quaters[selectedQuater].end_date + year);
      });
  
      $(document).on('focusout', 'input.form-control', function($this) {
        let form = 'form#' + $this.currentTarget.form.id;
        let point = parseFloat($(form + ' input#goal_point').val());
        let percent_completed = parseFloat($(form + ' input#goal_percent_completed').val());
        let achieved_point = Math.round(point * percent_completed) / 100;
  
        $(form + ' input#goal_achived_point').val(achieved_point);
        $(form + ' input#goal_point_achieved').val(achieved_point);
      });
  
      $(document).on('submit', 'form.review-confirmation', function(e) {
  
        e.preventDefault();
        let form = 'form#' + $(this).attr('id');
        let formData = $(this).serialize();
  
        $.ajax({
          type: 'POST',
          url: $(this).attr('action'),
          data: formData,
          dataType: 'JSON',
          encode: true,
        }).done(function (data) {
          $(form + " input.btn.btn-primary").attr('disabled','disabled');
          $(form + " div#review-success").html(data.notice);
          $(form + " div#review-success").show();
        });
  
      });
    });
  }
}