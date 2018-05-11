# grpcx

Ruby gRPC extensions/helpers


# Grpcx::Server

Drop-in replacement for `GRPC::RpcServer`, that:

- handles [grpclb](https://github.com/bsm/grpclb/tree/master/ruby) load requests
- handles [GRPC health checking](https://github.com/grpc/grpc/blob/master/doc/health-checking.md) requests
- handles `ActiveRecord` connection (auto-connect + pooling)
- instruments each request with `ActiveSupport::Notifications` (available as `process_action.grpc`, includes `action: METHOD_NAME` data)
- includes `ActiveSupport::Rescuable` and transforms most common `ActiveRecord::ActiveRecordError`-s into `GRPC::BadStatus` ones

Basic usage:

```ruby
require 'grpcx/server' # or just 'grpcx'

opts = {
  pool_size:            ENV['GRPC_SERVER_THREADS'].to_i, # default, unless provided in opts hash and ENV var is set
  max_waiting_requests: ENV['GRPC_SERVER_QUEUE'].to_i,   # default, unless provided in opts hash and ENV var is set
  # and any other options, accepted by GRPC::RpcServer's constructor
}

# proceed as with usual GRPC::RpcServer:
server = Grpcx::Server.new(opts)
server.handle(MyService.new)
server.add_http2_port '127.0.0.1:8080', :this_port_is_insecure
server.run_till_terminated
```

Also, can be extended:

```ruby
class MyServer < Grpcx::Server
  # optional custom error handling:
  rescue_from 'MyError' do |e|
    raise Grpc::BadStatus.new(e.to_s, my_extra: e.my_extra)
  end
end
```


## Using with [Datadog::Notifications](https://github.com/bsm/datadog-notifications)

```ruby
module Datadog::Notifications::Plugins
  class GRPC < Base

    def initialize(opts={})
      super
      Datadog::Notifications.subscribe 'process_action.grpc' do |reporter, event|
        record(reporter, event)
      end
    end

    private

    def record(reporter, event)
      action = event.payload[:action]
      status = event.payload[:exception] ? 'error' : 'ok'
      tags = self.tags + ["rpc:#{action}", "status:#{status}"]

      reporter.batch do
        reporter.increment 'grpc.request', tags: tags
        reporter.timing 'grpc.request.time', event.duration, tags: tags
      end
    end

  end
end

Datadog::Notifications.configure do |c|
  c.use Datadog::Notifications::Plugins::GRPC
end if RUNNING_IN_PROD?
```


## Using with [Sentry](https://sentry.io/)/[Raven](https://github.com/getsentry/raven-ruby)

```ruby
ActiveSupport::Notifications.subscribe('process_action.grpc') do |_name, _start, _finish, _id, payload|
  e = payload[:exception_object]
  next unless e

  Raven.capture_exception(e)
end

Raven.configure do |config|
  config.should_capture = proc {|e|
    !e.is_a?(GRPC::BadStatus) # skip GRPC::BadStatus, but report everything else
  }
end
```

Similar approach can be used for logging.
