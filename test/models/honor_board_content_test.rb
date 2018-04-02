require 'test_helper'

class HonorBoardContentTest < ActiveSupport::TestCase
  def setup
    @content = HonorBoardContent.new
    @content.name = "saimun"
    @content.reason = "this is a demo reason"
    @content.photo = "new3.jpg"
  end


  test "name should start with Uppercase letter" do

  end
end