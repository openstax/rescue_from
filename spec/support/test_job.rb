class TestJob < ActiveJob::Base
  queue_as :default

  def perform(ex)
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
