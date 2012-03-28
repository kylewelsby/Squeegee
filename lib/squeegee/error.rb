module Squeegee
  module Error
    class InvalidParams < ArgumentError;end
    class PageMissingContent < NoMethodError;end
    class Unauthorized < NoMethodError;end
  end
end
