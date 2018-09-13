# grpcx

Ruby gRPC extensions/helpers


# Grpcx::Server

Mixin for `GRPC::RpcServer`:

- handles [GRPC health checks](https://github.com/grpc/grpc/blob/master/doc/health-checking.md) requests
- handles `ActiveRecord` connection (auto-connect + pooling)
- instruments each request with `ActiveSupport::Notifications` (available as `process_action.grpc`, includes `service: 'package.name.ServiceName', action: 'underscored_action_name'` data)
- includes `ActiveSupport::Rescuable` and transforms most common `ActiveRecord::ActiveRecordError`-s into `GRPC::BadStatus` ones


Example:

```ruby
require 'grpcx/server' # or just 'grpcx'

class MyServer < GRPC::RpcServer
  include Grpcx::Server

  # optional custom error handling:
  rescue_from 'MyError' do |e|
    raise Grpc::BadStatus.new(e.to_s, my_extra: e.my_extra)
  end
end

# proceed as with usual GRPC::RpcServer:
server = MyServer.new(...)
server.handle(MyService.new)
server.add_http2_port '127.0.0.1:8080', :this_port_is_insecure
server.run_till_terminated
```

Recommended to be used with [Grpclb::Server](https://github.com/bsm/grpclb/tree/master/ruby):

```ruby
require 'grpclb/server'
require 'grpcx/server'

class MyServer < Grpclb::Server
  include Grpcx::Server
end

...
```


## Using with [Datadog::Notifications](https://github.com/bsm/datadog-notifications)

Since version >= [0.5.4](https://github.com/bsm/datadog-notifications/releases/tag/v0.5.4)

```ruby
Datadog::Notifications.configure do |c|
  c.use Datadog::Notifications::Plugins::GRPC
end if RUNNING_IN_PROD?
```


## Using with [Sentry](https://sentry.io/)/[Raven](https://github.com/getsentry/raven-ruby)

```ruby
ActiveSupport::Notifications.subscribe(Grpcx::Server::Interceptors::Instrumentation::METRIC_NAME) do |_name, _start, _finish, _id, payload|
  e = payload[:exception_object]
  next unless e

  Raven.capture_exception(e, extra: {
    'service' => payload[:service],
    'action'  => payload[:action],
  })
end

Raven.configure do |config|
  config.should_capture = proc {|e|
    !e.is_a?(GRPC::BadStatus) # skip GRPC::BadStatus, but report everything else
  }
end
```

Similar approach can be used for logging.
