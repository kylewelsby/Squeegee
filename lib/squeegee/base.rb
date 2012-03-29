module Squeegee
  class Base
    attr_writer :keys, :agent, :amount, :paid, :due_at
    def params(args)
      missing_keys = []
      return unless defined? @keys
      @keys.each do |key|
        missing_keys << key unless args.has_key?(key.to_sym)
      end
      if missing_keys.any?
        raise Error::InvalidParams,
          "missing parameters #{missing_keys.map {|key| "`#{key}` "}.join}"
      end
    end

    def get(url)
      @agent ||= Mechanize.new
      @agent.log = Logger.new 'squeegee.log'
      @agent.user_agent = "Mozilla/5.0 (Squeegee)"
      @agent.default_encoding = "utf8"
      @agent.get(url)
    end
  end
end
