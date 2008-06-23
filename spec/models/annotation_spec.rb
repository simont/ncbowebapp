require File.dirname(__FILE__) + '/../spec_helper'

describe Annotation do
  before(:each) do
    @annotation = Annotation.new
  end

  it "should be valid" do
    @annotation.should be_valid
  end
end
