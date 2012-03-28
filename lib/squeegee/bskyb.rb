module Squeegee
  class BSkyB < Base
    LOGIN_URL = "https://skyid.sky.com/signin/accountmanagement"
    ACCOUNT_URL = "https://myaccount.sky.com/?action=viewbills"

    FIELD = {
      username: 'username',
      password: 'password'
    }

    attr_accessor :due_at, :amount, :paid

    def initialize(args = {})
      @keys = %w(username password)

      params(args)
      @username = args.delete(:username)
      @password = args.delete(:password)

      authenticate!
      get_statement
    end

    private

    def authenticate!
      page = get(LOGIN_URL)
      form = page.form_with(name: 'signinform')

      form[FIELD[:username]] = @username
      form[FIELD[:password]] = @password

      @agent.submit(form, form.buttons.first)
    end

    def get_statement
      page = get(ACCOUNT_URL)
      amount = page.search(
        "#outstanding_balance_total span.money-left"
      ).inner_text.gsub(/\.|,/,'').match(/\d{1,}/)

      @amount = amount[0].to_i if amount

      due_at = page.search(
        "#outstanding_balance_box_label h5 span"
      ).inner_text.match(/(\d{2})\/(\d{2})\/(\d{2})/)

      @due_at = Date.parse("20#{due_at[3]}-#{due_at[2]}-#{due_at[1]}")if due_at

      @paid = page.search(
        "#payments .bill .desc"
      ).inner_text.downcase.include?("received")

    rescue NoMethodError => e
      raise Error::PageMissingContent, "Can't find something on the page"
    end
  end
end
