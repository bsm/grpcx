require 'active_support/core_ext/hash/indifferent_access'
require 'set'

module Grpcx
  # Entity releated helpers
  module Entity
    extend self

    TRUE_VALUES = [true, 1, "1", "t", "T", "true", "TRUE", "on", "ON"].to_set.freeze

    # @param [Class] msgclass messagepack message class
    # @param [Hash] attrs attributes to assign
    def build(msgclass, attrs={})
      attrs  = ActiveSupport::HashWithIndifferentAccess.new(attrs)
      fields = {}
      msgclass.descriptor.each do |field|
        next unless attrs.key?(field.name)

        source = attrs[field.name]
        target = nil

        case field.type
        when :int64, :int32
          target = convert(field, source, &:to_i)
        when :float, :double
          target = convert(field, source, &:to_f)
        when :string
          target = convert(field, source, &:to_s)
        when :bool
          target = convert(field, source) do |vv|
            TRUE_VALUES.include?(vv)
          end
        when :enum
          target = convert(field, source) do |vv|
            case vv
            when Integer
              vv
            when String, Symbol
              field.subtype.lookup_name(vv.to_s.upcase.to_sym)
            end
          end
        when :message
          target = convert(field, source) do |vv|
            build(field.subtype.msgclass, vv)
          end
        end

        fields[field.name] = target if target
      end

      msgclass.new(fields)
    end

    def convert(field, value, &block)
      field.label == :repeated ? value.map(&block) : block.call(value) if value
    end
    private :convert

  end
end
