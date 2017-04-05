class AdminLeavesController < ApplicationController

  layout 'leave'

  def index
    @leaves = Leave.all
  end

end
