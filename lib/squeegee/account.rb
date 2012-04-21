module Squeegee
  # Account
  #
  # Generic account with validations on specific parameters
  class Account
    attr_accessor :name, :amount, :due_at, :paid, :uid
    def initialize(args={})
      %w(name uid amount due_at).each do |key|
        raise Squeegee::Error::InvalidParams,
          "missing attribute `#{key}`" unless args.has_key?(key.to_sym)
      end
      @name = args[:name]
      @amount = args[:amount]
      @due_at = args[:due_at]
      @paid = args[:paid]
      @uid = args[:uid]
    end
  end
end
