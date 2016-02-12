worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout 60
preload_app true

listen "#{ENV.fetch('DEPLOY_TO')}/shared/tmp/sockets/unicorn.sock"
pid "#{ENV.fetch('DEPLOY_TO')}/shared/tmp/pids/unicorn.pid"

working_directory "#{ENV.fetch('DEPLOY_TO')}/current"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    logger.info('Unicorn master intercepting TERM and sending myself QUIT instead')
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    logger.info('Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT')
  end

  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

stderr_path File.expand_path("#{ENV.fetch('DEPLOY_TO')}/shared/log/error_unicorn.log")
stdout_path File.expand_path("#{ENV.fetch('DEPLOY_TO')}/shared/log/unicorn.log")
