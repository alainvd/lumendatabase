require 'logstash-logger'

class LumenLogger
  def self.init(**args)
    file_path = args[:path]

    if ENV['LOG_TO_LOGSTASH_FORMAT']
      path_parts = file_path.split('/')
      aliased_path = path_parts.take(path_parts.length - 1).join('/') + "/logstash_#{path_parts.last}"
      LogStashLogger.new(**args, type: :file, path: aliased_path)
    elsif ENV['RAILS_LOG_TO_STDOUT']
      logger = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = ::Logger::Formatter.new
      ActiveSupport::TaggedLogging.new(logger)
    else
      logger = ActiveSupport::Logger.new(file_path)
      logger.formatter = ::Logger::Formatter.new
      ActiveSupport::TaggedLogging.new(logger)
    end
  end

  def self.log_metrics(action, **data)
    # There is no possiblity to set a custom log level per logger in
    # logstash-logger, so we need to call error here, not great, not terrible.
    Lumen::METRICS_LOGGER.error(
      LogStash::Event.new(
        action: action,
        **data,
        **LumenLogger.current_user
      )
    )
  end

  def self.current_user
    user = {}
    if Current.user
      user = {
        user_id: Current.user.id,
        email: Current.user.email
      }
    end
    user
  end
end
