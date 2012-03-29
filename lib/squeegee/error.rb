module Squeegee
  module Error
    # Invalid Parameters - raised when ever a parameter is listed as missing
    class InvalidParams < ArgumentError;end
    # Page Missing Content - raised when the page expectations have changed
    class PageMissingContent < NoMethodError;end
    # Unauthenticated - raised when authentication fails.
    class Unauthenticated < NoMethodError;end
  end
end
