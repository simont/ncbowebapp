require File.dirname(__FILE__) + '/../spec_helper'

describe Analysis do
  before(:each) do
    @analysis = Analysis.new
  end

  it "should be valid" do
    @analysis.should be_valid
  end
end
