module Test
  class TestController < ActionController::Base
    use_openstax_exception_rescue

    def bad_action
      raise params[:exception].constantize
    end
  end

  test_routes = Proc.new do
    get 'bad_action' => 'test/test#bad_action'
  end

  Rails.application.routes.send(:eval_block, test_routes)
end
