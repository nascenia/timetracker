class LeavesController < InheritedResources::Base

  private

    def leave_params
      params.require(:leave).permit(:user_id, :reason, :leave_type, :status)
    end
end

