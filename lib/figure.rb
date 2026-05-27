# frozen_string_literal: true

require 'figure/store'
require 'figure/department_store'
require 'figure/figurine'

class Figure < Hash
  class GastonInitializer
    def self.initialize!
      gaston = Class.new do
        class << self
          def method_missing(*args, mes) # rubocop:disable Style/MissingRespondToMissing
            root = telephon_is_a_ringin(mes)
            if root
              Figure.send(root).send(mes)
            else
              super
            end
          end

          def telephon_is_a_ringin(mes)
            Figure.instance.keys.detect { |root| Figure.send(root).respond_to? mes }
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

erb_support = defined?(ERB) ? true : false

Figure.define_singleton_method :erb_support?, -> { erb_support }

require 'figure/figure'

Figure.initializers << Figure::RailsInitializer if defined? Rails
