# frozen_string_literal: true

class Figure < Hash
  module Store
    def []=(kls, val)
      self.class.send :define_method, kls, -> { custom_fetch kls } unless respond_to? kls
      super
    end

    def default(kls = nil)
      if kls && !default_store.has_key?(kls) && can_forward?
        self[:default]
      elsif default_store && kls
        default_store[kls]
      elsif has_key? :default
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
      return unless default_store && default_store.can_forward? && begin
        default_store.forward!
      rescue StandardError
        false
      end

      default_store.forward!.figures.reject { |l| respond_to?(l) }.each do |l|
        self.class.send :define_method, l, -> { default_store.forward![l] }
      end
    end

    def has_key?(key)
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

    def custom_fetch(kls)
      if self[kls].respond_to?(:can_forward?) && self[kls].can_forward?
        self[kls].forward!

      else
        self[kls]
      end
    end
  end
end
