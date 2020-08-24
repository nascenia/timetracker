class Timesheet < ActiveRecord::Base
  belongs_to :user
  belongs_to :project


  def self.to_csv_timesheet(options2= {})
    options = {}
    options[:col_sep] = "\t"

    @user = User.all
    @timesheets = Timesheet.all.where(project_id: options2[:project_id],
        date: options2[:start_date].tr("/", "-")..options2[:end_date].tr("/", "-")).order(date: :desc)
    options2[:end_date].tr("/", "-")


    CSV.generate(options) do |csv|
      csv << ['Date','Resource Name', 'Tittle', 'Card Number',
              'Card Link', 'Hours spent', 'Comments']
      @timesheets.each do |timesheet|

        minutes_hours_spent = timesheet[:minutes].to_f/60
        tatal_hours_spent = timesheet[:hours] +minutes_hours_spent
        resource_name = @user.find(timesheet[:user_id]).name
          csv <<[timesheet[:date],resource_name,timesheet[:task],
                 timesheet[:ticket_number],timesheet[:ticket_link],
                 tatal_hours_spent,timesheet[:description]]
      end
    end
  end

end
