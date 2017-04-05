class ExclusionDatesController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :find_context
  before_action :find_excluded

  def show
  end

  def new
  end

  def edit
  end

  def create
    @excluded_date = @context.exclusion_dates.new(exclusion_date_params)

    if @excluded_date.save
      redirect_to context_path(@context),
                  notice: 'The exclusion date has been successfully created.'
    else
      render :new
    end
  end

  def update
  end

  def destroy
  end

  private

  def find_context
    @context = if params[:weekend_id]
                 Weekend.find_by(id: params[:weekend_id])
               elsif params[:holiday_scheme_id]
                 HolidayScheme.find_by(id: params[:holiday_scheme_id])
               end
  end

  def find_excluded
    @excluded = if @weekend
                  @weekend.exclusion_dates.find_by(id: params[:id])
                elsif @holiday_scheme
                  @holiday_scheme.exclusion_dates.find_by(id: params[:id])
                end
  end

  def exclusion_date_params
    params.require(:exclusion_date).permit(:date)
  end

  def context_path(context)
    if Weekend === context
      weekends_path
    elsif HolidayScheme == context
      holiday_schemes_path
    end
  end
end
