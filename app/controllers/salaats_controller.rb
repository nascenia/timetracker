class SalaatsController < ApplicationController

  before_action :authenticate_user!

  def index
    @salaats = Salaat.all

    respond_to do |format|
      format.js
    end
  end

  def show

  end

  def new

  end

  def edit

  end

  def create

  end

  def update

  end

  def destroy

  end

  private

end
