class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leave
  before_action :set_comment, only: [:edit, :update, :destroy]
  
  layout 'leave'

  def new; end

  def create
    @comment = @leave.comments.new(comment_params)
    @comment.user = current_user
    notice = @comment.save ? 'Comment created' : 'No comment created'
    redirect_to leave_path(@leave), notice: notice
  end

  def edit; end

  def update
    if @comment.update(comment_params)
      flash[:notice] = 'Comment edited successfully.'
      redirect_to leave_path(@comment.leave)
    else
      flash[:warning] = 'Comment not edited successfully.'
      redirect_to leave_path(@comment.leave)
    end
  end

  def destroy
    if @comment.destroy
      flash[:notice] = 'Comment deleted successfully.'
      redirect_to leave_path(@comment.leave)
    else
      flash[:warning] = 'Comment not deleted successfully.'
      redirect_to leave_path(@comment.leave)
    end
  end

  private

  def set_leave
    @leave = Leave.find_by(id: params[:leave_id])
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :leave_id)
  end
end
