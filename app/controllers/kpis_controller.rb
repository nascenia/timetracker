class KpisController < InheritedResources::Base

  layout 'time_tracker'

  before_action :set_kpi, only: [:show, :edit, :update, :destroy]

  # GET /kpis
  def index
    user_id = params[:kpi].blank? ? current_user.id : params[:kpi][:user_id]
    @kpis  = Kpi.search(params[:kpi], user_id)
    @team   = User.active.where(ttf: current_user)
  end

  # GET /kpis/1
  def show
  end

  # GET /kpis/new
  def new
    @kpi              = Kpi.new
    @kpi_templates    = KpiTemplate.published
  end

  # GET /kpis/1/edit
  def edit
    @kpi_templates    = KpiTemplate.published
    @team             = User.active.where(ttf: current_user)
  end

  # POST /kpis
  def create
    @kpi = Kpi.new(kpi_params)

    if @kpi.save
      redirect_to employees_path notice: 'KPI was successfully assigned to the employee.'
    else
      render :new
    end
  end

  # PATCH/PUT /kpis/1
  def update
    if @kpi.update(kpi_params)
      respond_to do |format|
        format.html { redirect_to kpis_url, notice: 'KPI was successfully updated.' }
        format.js   { render json: { status: 200, notice: 'Review submitted successfully.' }}
      end
    else
      render :edit
    end
  end

  # DELETE /kpis/1
  def destroy
    @kpi.destroy
    redirect_to kpis_url, notice: 'KPI was successfully destroyed.'
  end

  # GET /kpis/review
  def review
    user_id = params[:kpi].blank? ? current_user.id : params[:kpi][:user_id]
    @kpis  = Kpi.search(params[:kpi], user_id)
    @team   = User.active.where(ttf: current_user)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_kpi
    @kpi = Kpi.find(params[:id])
  end

  def kpi_params
    params.require(:kpi).permit(:title, :description, :score, :start_date, :end_date, :status)
  end
end
