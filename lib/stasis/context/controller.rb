class Stasis
  class Context
    class Controller
      
      attr_reader :_
      include Plugin::Helpers
      
      def initialize(path, root)
        @_ = {
          :dir => File.dirname(path),
          :path => path,
          :plugins => _find_plugins,
          :root => root
        }
        _bind_plugins(:controller_method)
        instance_eval File.read(path), path
      end

      def resolve(path)
        if path.nil?
          nil
        elsif path.is_a?(Regexp)
          path
        elsif File.file?(p = File.expand_path("#{_[:dir]}/#{path}"))
          p
        elsif File.file?(p = File.expand_path("#{_[:root]}/#{path}"))
          p
        elsif File.file?(path)
          path
        else
          false
        end
      end
    end
  end
end