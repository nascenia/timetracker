class SuperAdminLeavesController < ApplicationController

  before_action :authenticate_admin_user!
  layout 'leave'

  def index
    @leaves = Leave.all
  end

end
