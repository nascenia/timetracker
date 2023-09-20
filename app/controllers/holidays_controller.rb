class HolidaysController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :get_holiday, only: [:edit, :update, :destroy]

  layout 'leave'

  def new
    @holiday = Holiday.new
    @holiday_scheme = HolidayScheme.find(params['scheme_id'].to_i)
  end

  def create
    holiday = Holiday.new(holiday_params)

    if holiday.save
      flash[:notice] = 'Holiday created successfully.'

      redirect_to holiday_scheme_path(holiday.holiday_scheme)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @holiday.update(holiday_params)
      redirect_to holiday_scheme_path(@holiday_scheme)
    end
  end

  def destroy
    if @holiday.destroy
      redirect_to holiday_scheme_path(@holiday_scheme)
    end
  end

  private

  def holiday_params
    params.require(:holiday).permit(:name, :date, :holiday_scheme_id)
  end

  def get_holiday
    @holiday = Holiday.find(params[:id])
    @holiday_scheme = @holiday.holiday_scheme
  end
end
