module OpenStax
  module RescueFrom
    class ExceptionCauseProxy < ExceptionProxy
      def logger_backtrace
        first_backtrace_line
      end
    end
  end
end
