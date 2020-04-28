class PreRegistrationsController < ApplicationController
    layout 'time_tracker'

    def index
        @pre_registration_all = PreRegistration.all.where(step_no: 1)
        @holiday_scheme = HolidayScheme.all
        @weekend_scheme = Weekend.all
        @ttf_list = User.active.where(role: 2)
    end
    def new
        @pre_registration = PreRegistration.new
        @pre_registration_all = PreRegistration.all.where(step_no: 1)
        @holiday_scheme = HolidayScheme.all
        @weekend_scheme = Weekend.all
        @ttf_list = User.active.where(role: 2)
    end

    def create
        pre_registration = PreRegistration.new(pre_registration_params)
        if pre_registration_params[:packReady].to_s == "0"
            pre_registration_params[:packReady] = false
        else
            pre_registration_params[:packReady] = true
        end
        if pre_registration_params[:NdaSigned].to_s == "0"
            pre_registration_params[:NdaSigned] = false
        else
            pre_registration_params[:NdaSigned] = true
        end
        if pre_registration_params[:workstationReady].to_s == "0"
            pre_registration_params[:workstationReady] = false
        else
            pre_registration_params[:workstationReady] = true
        end
        pre_registration.step_no = 1
        if pre_registration.save
            redirect_to root_path
        end
    end
    def delete
    end
    def destroy
        @pre_registration = PreRegistration.find(params[:id])
        if @pre_registration.present?
            @pre_registration.destroy
        end
        redirect_to new_pre_registration_path
    end
    def edit
        @pre_registration = PreRegistration.find(params[:id])
        @holiday_scheme = HolidayScheme.all
        @weekend_scheme = Weekend.all
        @ttf_list = User.active.where(role: 2)
        if params[:format] != "1"
            @is_for_admin = "23"
        else
            @is_for_admin = "22"
        end
    end
    def update
        pre_registration = PreRegistration.find params[:id]
        if params[:selected] == "23"
            pre_registration.step_no = 2
        end
        if pre_registration.update(pre_registration_params)
            if params[:selected] == "23"
                redirect_to root_path
                else
                redirect_to new_pre_registration_path
            end
        end
    end
    private
    # Using a private method to encapsulate the permissible parameters is
    # a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.
    def pre_registration_params
        params.require(:pre_registration).permit(:name,
        :companyEmail,
        :joiningDate,
        :datetime,
        :NdaSigned,
        :user_id,
        :emailGroup,
        :contactNumber,
        :personalEmail,
        :companyEmail,
        :holiday_scheme_id,
        :weekend_id,
        :workstationReady,
        :packReady )
    end
end
