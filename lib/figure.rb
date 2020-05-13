require 'figure/store'
require 'figure/department_store'
require 'figure/figurine'

class Figure < Hash
  class GastonInitializer
    def self.initialize!
      gaston = Class.new do
        class << self
          def method_missing(*args, m)
            if root = telephon_is_a_ringin(m)
              Figure.send(root).send(m)
            else
              super
            end
          end

          def telephon_is_a_ringin(m)
            Figure.instance.keys.detect { |root| Figure.send(root).respond_to? m }
          end
        end
      end

      Object.const_set 'Gaston', gaston
    end
  end
end

class Figure < Hash
  class RailsInitializer
    def self.initialize!
      Figure.configure do |config|
        config.responders << Rails
        config.config_directories << Rails.root.join('config')
      end
    end
  end
end

if defined? Rails
  Figure.initializers << Figure::RailsInitializer
end

erb_support = !!defined?(ERB)

Figure.define_singleton_method :erb_support?, ->{ erb_support }

require 'figure/figure'
