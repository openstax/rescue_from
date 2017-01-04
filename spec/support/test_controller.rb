module Test
  class TestController < ActionController::Base
    use_openstax_exception_rescue

    def bad_action
      ex = params[:exception]
      ex_class = ex.constantize

      raise case ex
      when 'ActionController::RoutingError'
        ex_class.new('Not found')
      when 'ActionController::ParameterMissing'
        ex_class.new('a_param')
      when 'ActionView::MissingTemplate'
        ex_class.new(['some/path', 'other/path'], 'some/path', [], nil, '')
      else
        ex_class.new
      end
    end
  end

  test_routes = Proc.new do
    get 'bad_action' => 'test/test#bad_action'
  end

  Rails.application.routes.send(:eval_block, test_routes)
end
