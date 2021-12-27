class KpiItemsController < InheritedResources::Base

  private

    def kpi_item_params
      params.require(:kpi_item).permit(:title, :description, :score, :start_date, :end_date, :status)
    end
end

