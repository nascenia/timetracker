module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  def copyright_year
    Time.zone.now.year
  end

  def is_late_attendance? check_in_time
    Time.at(check_in_time).strftime('%H:%M') > Time.at(Time.parse(Attendance::USUAL_OFFICE_TIME)).strftime('%H:%M')
  end

  def is_checked_in? attendance

    check_in_button = 'btn-success'

    unless attendance.nil?
      check_in_button = attendance.in_time.present? && attendance.out_time.nil? ? 'btn-default disabled' : 'btn-success'
    end

    return check_in_button
  end

  def is_checked_out? attendance
    unless attendance.nil?
      attendance.out_time.present? ? 'btn-default disabled' : 'btn-danger'
    end
  end

  def get_humanize_date date
    date.present? ? date.strftime('%B %d, %Y') : '-'
  end

  def get_formatted_date date
    date.present? ? date.strftime('%d-%m-%Y') : '-'
  end

  def get_formatted_time time
     time.present? ? Time.at(time).utc.strftime('%I:%M %p') : '-'
  end

  def link_to_modal(name = nil, options = {}, html_options = {}, &block)
    data_options = { toggle: 'modal', target: '#modal-window', keyboard: true, turbolinks: false }
    modal_options = { remote: true }

    if block.present?
      data_options = data_options.merge(options[:data]) if options[:data]
      options = modal_options.merge(options).merge(data: data_options)
    else
      data_options = data_options.merge(html_options[:data]) if html_options[:data]
      html_options = modal_options.merge(html_options).merge(data: data_options)
    end
    link_to name, options, html_options, &block
  end

  def link_to_modal_if(condition, name = nil, options = {}, html_options = {}, &block)
    if condition
      link_to_modal(name, options, html_options, &block)
    elsif block.present?
      capture(&block)
    else
      name
    end
  end

  def phone_number_link(text)
    sets_of_numbers = text.scan(/[0-9]+/)
    number = "+1-#{sets_of_numbers.join('-')}"
    link_to text, "tel:#{number}"
  end

  def unannounced?(leave)
    leave.leave_type == Leave::UNANNOUNCED
  end

  def count_employee
    PreRegistration.where(step_no: 2..3).count
  end

  def add_employee
    PreRegistration.where(step_no: 2).count
  end

  def employee_onboard
    PreRegistration.where(step_no: 3).count
  end

  def hidden_field_tag(name, value = true, options = {})
    text_field_tag(name, value, options.merge(type: :hidden))
  end

  def blank_space count=1
    space = ''
    count.times do
      space = space + '&nbsp;'
    end
    space.html_safe
  end

  def kpi_status_str status
    case status
    when Kpi::STATUSES[:saved]
      'Saved'
    when Kpi::STATUSES[:submitted]
      'Submitted'
    when Kpi::STATUSES[:inreview]
      'In-review'
    when Kpi::STATUSES[:approved]
      'Approved'
    else
      '-'
    end
  end
end
