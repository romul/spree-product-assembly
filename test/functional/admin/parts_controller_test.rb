require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
Admin::PartsController.class_eval { def rescue_action(e) raise e end }

class Admin::PartsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::PartsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
