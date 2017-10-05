class TestJob < ActiveJob::Base
  queue_as :default

  def perform(ex)
    raise case ex
          when 'ActionView::MissingTemplate'
            ex.constantize.new(['some/path', 'other/path'], 'some/path', [], nil, '')
          when 'ActionController::RoutingError'
            ex.constantize.new('Not found')
          when 'ActionController::ParameterMissing'
            ex.constantize.new('some_param')
          else
            ex.constantize
          end
  end
end
