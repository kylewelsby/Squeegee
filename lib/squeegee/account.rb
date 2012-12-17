module Squeegee
  # Account
  #
  # Generic account with validations on specific parameters
  class Account < Base
    attr_accessor :name, :amount, :due_at, :paid, :uid, :number
    def initialize(args={})
      @keys = %w(name uid amount due_at)
      params(args)

      args.each do |attribute, value|
        send(:"#{attribute}=", value)
      end
    end
  end
end
