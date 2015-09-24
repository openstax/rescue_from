module Test
  class TestController < ActionController::Base
    use_openstax_exception_rescue

    def bad_action
      exception = params[:exception].constantize
      raise case params[:exception]
            when 'ActionController::RoutingError'
              exception.new('routing error')
            when 'ActionView::MissingTemplate'
              exception.new(['some/path', 'other/path'], 'some/path', [], nil, '')
            else
              exception.new
            end
    end
  end

  test_routes = Proc.new do
    get 'bad_action' => 'test/test#bad_action'
  end

  Rails.application.routes.send(:eval_block, test_routes)
end
