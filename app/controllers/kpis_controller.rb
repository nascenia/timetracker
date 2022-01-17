class KpisController < InheritedResources::Base

  layout 'time_tracker'

  before_action :set_kpi, only: [:show, :edit, :update, :destroy]

  # GET /kpis
  def index
    user_id       = params[:kpi].blank? ? current_user.id : params[:kpi][:user_id].to_i
    @kpis         = Kpi.search(params[:kpi], user_id)
    user          = User.find(user_id)

    if !user_id.eql?(current_user.id)
      unless user.ttf_id.eql?(current_user.id)
        redirect_to kpis_path, notice: 'Sorry, You have no permission to access.'
      end
    end

    @team   = User.active.where(ttf: current_user)
  end

  # GET /kpis/1
  def show
  end

  # GET /kpis/new
  def new

    unless current_user.admin?
      redirect_to kpis_path, notice: 'Sorry, You have no permission to access.'
    end

    if params[:user_id].nil?
      redirect_to employees_path, notice: 'You have to select employee, please select an employee.'
      return
    end

    @kpi              = Kpi.new
    @kpi_templates    = KpiTemplate.published
    @user             = User.find(params[:user_id])
  end

  # GET /kpis/1/edit
  def edit
    @kpi_templates    = KpiTemplate.published
    @team             = User.active.where(ttf: current_user)
  end

  # POST /kpis
  def create
    kpi_template = KpiTemplate.find(params[:kpi][:kpi_template_id])
    user = User.find(params[:kpi][:user_id].to_i)
    user.kpi_template = kpi_template
    user.save

    redirect_to employees_path, notice: 'KPI was successfully assigned to the employee.'
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

  # POST /kpis/review
  def review
    unless params[:kpi].blank?
      user_id   = params[:kpi].blank? ? current_user.id : params[:kpi][:user_id]
      @kpi      = Kpi.date_range('01-01-2022', '31-03-2022').where(user_id: user_id).last
      @kpi      = Kpi.new(kpi_params) if @kpi.nil?
      item_ids  = params[:kpi_ids].map{|id| id.to_i}
      data      = Hash.new     
      item_ids.each_with_index do |id, i|
        data[id] = params[:kpi_score][i]
      end
      @kpi.data    = data.to_json
      @kpi.status  = Kpi::STATUSES[:inreview] if params[:commit].eql?('Submit')
      @kpi.status  = Kpi::STATUSES[:approved] if params[:commit].eql?('Review and approve')
      @kpi.save

      #commit = 'saved' 
      commit = 'submitted' if params[:commit].eql?('Submit')
      #commit = 'reviewed and approved' if params[:commit].eql?('Review and approve')

      redirect_to kpis_path, notice: "KPI score #{commit} successfully."
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_kpi
    @kpi = Kpi.find(params[:id])
  end

  def kpi_params
    params.require(:kpi).permit(
      :user_id,
      :start_date, 
      :end_date,
      :ttf_comment,
      :team_member_comment, 
      :status)
  end
end

