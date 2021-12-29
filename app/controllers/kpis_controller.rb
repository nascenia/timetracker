class KpisController < InheritedResources::Base

  private

    def kpi_params
      params.require(:kpi).permit(:title, :description, :score, :start_date, :end_date, :status)
    end
end

