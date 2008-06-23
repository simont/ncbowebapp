class AnalysesController < ApplicationController
  
  def list
    @analyses = Analysis.find(:all)
  end
  
  def show
    @analysis = Analysis.find(params[:id])
  end
end
