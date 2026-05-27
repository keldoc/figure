# frozen_string_literal: true

class Figure < Hash
  module Store
    def []=(klass, val)
      self.class.send :define_method, klass, -> { custom_fetch klass } unless respond_to? klass
      super
    end

    def default(klass = nil)
      if klass && !default_store.has_key?(klass) && can_forward? # rubocop:disable Style/PreferredHashMethods
        self[:default]
      elsif default_store && klass
        default_store[klass]
      elsif has_key? :default # rubocop:disable Style/PreferredHashMethods
        self[:default]
      end
    end

    def merge!(hash)
      hash.each do |k, v|
        self[k] = if v.is_a? Hash
                    new_store k, v, self.class
                  elsif v.is_a? Array
                    v.map do |i|
                      i.is_a?(Hash) ? new_store(k, i, self.class) : i
                    end
                  else
                    v
                  end
      end
    end

    def complete_defaults
      return unless default_store&.can_forward?

      forwarded_store = default_store.forward!
      return unless forwarded_store

      forwarded_store.figures.reject { |figure| respond_to?(figure) }.each do |figure|
        self.class.send(:define_method, figure) do
          default_store.forward![figure]
        end
      end
    rescue StandardError
      false
    end

    def has_key?(key) # rubocop:disable Naming/PredicatePrefix
      [key.to_s, key.to_sym].detect { |k| super(k) }
    end

    def figures
      keys.tap { |f| f.concat default_store.figures if default_store }.uniq
    end

    private

    def default_store
      @default_store ||= begin
        self.class.ancestors[1].instance
      rescue StandardError
        nil
      end
    end

    def custom_fetch(klass)
      if self[klass].respond_to?(:can_forward?) && self[klass].can_forward?
        self[klass].forward!

      else
        self[klass]
      end
    end
  end
end
