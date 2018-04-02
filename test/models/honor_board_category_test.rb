require 'test_helper'

class HonorBoardCategoryTest < ActiveSupport::TestCase
  def setup
    @category = HonorBoardCategory.new(category: "Proactive")

  end

  test "category should be valid" do
    assert @category.valid?

  end

  test "category should be present" do
    @category.category = " "
    assert_not @category.valid?
  end

  test "category should be unique" do
    @category.save
    categoryfake = Category.new(category: "Proactive")
    assert_not categoryfake.valid?

  end

  test "category should not be too long" do
    @category.category = "a" * 301
    assert_not @category.valid?
  end

  test "category should not be too short" do
    @category.category = "cc"
    assert_not @category.valid?
  end
end