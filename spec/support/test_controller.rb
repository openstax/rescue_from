module Test
  class TestController < ActionController::Base
    use_openstax_exception_rescue

    def bad_action
      ex = params[:exception]
      raise case ex
            when 'ActionController::RoutingError'
              ex.constantize.new('Not found')
            when 'ActionView::MissingTemplate'
              ex.constantize.new(['some/path', 'other/path'], 'some/path', [], nil, '')
            else
              ex.constantize
            end
    end
  end

  test_routes = Proc.new do
    get 'bad_action' => 'test/test#bad_action'
  end

  Rails.application.routes.send(:eval_block, test_routes)
end
