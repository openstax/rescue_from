module Test
  class TestController < ActionController::Base
    openstax_rescue

    def bad_action
      raise case params[:exception]
            when 'ActionController::RoutingError'
              params[:exception].constantize.new('routing error')
            when 'Apipie::ParamMissing'
              params[:exception].constantize.new('apipie error')
            when 'ActionView::MissingTemplate'
              params[:exception].constantize.new(['some/path', 'other/path'],
                                                 'some/path', [], nil, '')
            else
              params[:exception].constantize.new
            end
    end
  end

  test_routes = Proc.new do
    get 'bad_action' => 'test/test#bad_action'
  end

  Rails.application.routes.send(:eval_block, test_routes)
end
