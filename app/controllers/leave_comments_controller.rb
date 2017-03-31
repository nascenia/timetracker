class LeaveCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leave

  def create
    @leave_comment = @leave.leave_comments.create(leave_comment_params)
  end

  private

  def set_leave
    @leave = Leave.find_by(id: params[:leave_id])
  end

  def set_leave_comment
    @leave_comment = @leave.leave_comments.find_by(id: params[:id])
  end

  def leave_comment_params
    params.require(:leave_comment).permit(:comment, :leave_id)
  end
end
