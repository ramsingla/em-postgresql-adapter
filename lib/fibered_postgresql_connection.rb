require 'fiber'
require 'eventmachine'
require 'pg'

module EM
  module DB
    class FiberedPostgresConnection < PGconn

      module Watcher
        def initialize(client, deferable)
          @client = client
          @deferable = deferable
        end

        def notify_readable
          begin
            detach

            @client.consume_input while @client.is_busy

            res, data = 0, []
            while res != nil
              res = @client.get_result
              data << res unless res.nil?
            end

            @deferable.succeed(data.last)
          rescue Exception => e
            @deferable.fail(e)
          end
        end
      end

      # Assuming the use of EM fiber extensions and that the exec is run in
      # the context of a fiber. One that have the value :neverblock set to true.
      # All neverblock IO classes check this value, setting it to false will force
      # the execution in a blocking way.
      def exec(sql)
        # TODO Still not "killing the query process"-proof
        # In some cases, the query is simply sent but the fiber never yields
        if ::EM.reactor_running?
          send_query sql
          deferrable = ::EM::DefaultDeferrable.new
          ::EM.watch(self.socket, Watcher, self, deferrable).notify_readable = true
          fiber = Fiber.current
          deferrable.callback do |result|
            fiber.resume(result)
          end
          deferrable.errback do |err|
            fiber.resume(err)
          end
          Fiber.yield.tap do |result|
            raise result if result.is_a?(Exception)
          end
        else
          super(sql)
        end
      end

      alias_method :query, :exec

    end #FiberedPostgresConnection
  end #DB
end #EM
