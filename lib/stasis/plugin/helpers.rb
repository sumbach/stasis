class Stasis
  class Plugin
    module Helpers

      def _bind_plugins(type)
        _[:plugins].each do |plugin|
          methods = plugin.class._[:methods][type]
          if methods.is_a?(::Array)
            methods = methods.inject({}) do |hash, method|
              hash[method] = method
              hash
            end
          end
          (methods || {}).each do |method, real_method|
            self.instance_eval <<-EVAL
              def #{method}(*args, &block)
                _send_to_plugin_by_method(#{real_method.inspect}, *args, &block)
              end
            EVAL
          end
        end
      end
      
      def _find_plugins
        plugins = Stasis.constants.collect { |klass|
          klass = klass.to_s
          unless %w(Context Gems Plugin).include?(klass)
            eval("::Stasis::#{klass}").new
          end
        }.compact
        plugins.sort! { |a, b| a.class._[:priority] <=> b.class._[:priority] }
      end

      def _send_to_plugin_by_method(method, *args, &block)
        args = [ self ] + args
        _[:plugins].each do |plugin|
          if plugin.respond_to?(method)
            return plugin.send(method, *args, &block)
          end
        end
      end

      def _send_to_plugin_by_type(type, *args, &block)
        arg = [ self ].compact + args
        _[:plugins].each do |plugin|
          methods = plugin.class._[:methods][type]
          (methods || []).each do |method|
            if plugin.respond_to?(method)
              arg = plugin.send(method, *arg, &block)
            end
          end
        end
        if arg.length > args.length
          arg[1..-1]
        else
          arg
        end
      end
    end
  end
end