class AnalysesController < ApplicationController
  
  def list
    @analyses = Analysis.find(:all)
  end
  
  def show
    @analysis = Analysis.find(params[:id])
  end
  
  def index
    @analyses = Analysis.find(:all)
    redirect_to :action => 'list'
  end
  
end
