class KpisController < ApplicationController

  layout 'time_tracker'

  before_action :set_kpi, only: [:show, :edit, :update, :destroy, :comment]

  # GET /kpis
  def index
    user_id = current_user.id

    if params[:kpi].present? && params[:kpi][:personal_or_team].eql?('team') 
      user_id = params[:kpi][:team_member]
    end

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
    @user_kpis    = @kpi.nil? ? [] : JSON.parse(@kpi.data)
    kpi_template  = KpiTemplate.includes(:kpi_items).find(@kpi.user.kpi_template_id)
    @kpi_items    = kpi_template.kpi_items
  end

  # GET /kpis/new
  def new
    if current_user.kpi_template_id.blank?
      redirect_to kpis_path, notice: 'Sorry, you have not assigned any KPI. Please contact with HR/admin.'
      return
    end

    @kpi              = Kpi.new
    @kpi_template     = KpiTemplate.includes(:kpi_items).find(current_user.kpi_template_id)
  end

  # GET /kpis/1/edit
  def edit
    @team             = User.active.where(ttf: current_user)
    kpi_template      = KpiTemplate.includes(:kpi_items).find(@kpi.user.kpi_template_id)
    @kpi_items        = kpi_template.kpi_items
  end

  # POST /kpis
  def create
    # TODO: If there is already a KPI in the selected date show flash message and return in current page
    @kpi = Kpi.new(kpi_params)
    item_ids  = params[:kpi_item_ids].map{|id| id.to_i}
    data      = []
    item_ids.each_with_index do |item_id, i|
      data << { item_id: item_id, score: params[:kpi_item_score][i].to_f }
    end

    @kpi.data    = data.to_json
    @kpi.status  = Kpi::STATUSES[:draft] if params[:commit].eql?('Save')
    @kpi.status  = Kpi::STATUSES[:review_request] if params[:commit].eql?('Review request')
    @kpi.status  = Kpi::STATUSES[:reviewed] if params[:commit].eql?('Save & submit')

    if @kpi.save
      redirect_to kpis_path, notice: 'KPI was successfully created.'
    else
      redirect_to kpis_path, alert: 'Sorry, Unable to create KPI.'
    end
  end

  # PATCH/PUT /kpis/1
  def update
    kpi_attrs = kpi_params
    data      = []
    item_ids  = params[:kpi_item_ids].map{|id| id.to_i}
    item_ids.each_with_index do |item_id, i|
      data << { item_id: item_id, score: params[:kpi_item_score][i].to_f }
    end

    kpi_attrs[:data]    = data.to_json
    notice              = 'KPI updated successfully.'

    if params[:commit].eql?('Save')
      kpi_attrs[:status]  = Kpi::STATUSES[:draft]
      notice              = 'KPI saved successfully.'
    elsif params[:commit].eql?('Submit')
      kpi_attrs[:status]  = Kpi::STATUSES[:reviewed]
      notice              = 'KPI reviewed successfully.'
    elsif params[:commit].eql?('Submit for review')
      kpi_attrs[:status]  = Kpi::STATUSES[:review_request]
      notice              = 'KPI review request sent successfully.'
    end

    if @kpi.update(kpi_attrs)
      respond_to do |format|
        format.html { redirect_to kpis_url, notice: notice }
        format.js   { render json: { status: 200, notice: notice }}
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
    @team           = User.active.where(ttf: current_user)

    if !params[:kpi].blank?
      user_id         = params[:kpi][:user_id]
      @user           = User.find user_id
      if @user.kpi_template_id.blank?
        redirect_to kpis_path, notice: 'User have not assigned any KIP. Please contact with HR/admin.'
        return
      end
      kpi_template    = KpiTemplate.includes(:kpi_items).find(@user.kpi_template_id)
      @kpi_items      = kpi_template.kpi_items
      @kpi            = Kpi.new
    end
    
  end

  # POST kpi/:id/comment
  def comment
    if @kpi.update(kpi_params)
      respond_to do |format|
        format.html { redirect_to kpis_url, notice: 'KPI was successfully updated.' }
      end
    else
      redirect_to kpis_url, notice: 'Unable to add comment to KPI. Please try again later.'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_kpi
    @kpi = Kpi.includes(:user).find(params[:id])
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

