class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leave

  def new
  end

  def create
    @comment = @leave.comments.new(comment_params)
    @comment.user = current_user
    notice = @comment.save ? 'Comment created' : 'No comment created'
    redirect_to leave_path(@leave), notice: notice
  end

  private

  def set_leave
    @leave = Leave.find_by(id: params[:leave_id])
  end

  def set_comment
    @comment = @leave.comments.find_by(id: params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :leave_id)
  end
end
