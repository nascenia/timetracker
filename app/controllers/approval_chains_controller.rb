class ApprovalChainsController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'leave'

  def index
  end
end
