module Squeegee

  # British Sky Broadcasting (BSkyB) - Premium Television
  #
  class BSkyB < Base
    LOGIN_URL = "https://skyid.sky.com/signin/accountmanagement"
    ACCOUNT_URL = "https://myaccount.sky.com/?action=viewbills"

    FIELD = {
      username: 'username',
      password: 'password'
    }

    attr_accessor :accounts

    def initialize(args = {})
      @keys = %w(username password)

      params(args)
      @username = args.delete(:username)
      @password = args.delete(:password)

      @accounts = []

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

      account_id = page.search("#account_management_nav .account-number").
        inner_text.match(/\d{4,}/)[0].to_i

      amount_html = page.search(
        "#outstanding_balance_total span.money-left"
      ).inner_text.gsub(/\.|,/,'').match(/\d{1,}/)

      amount = amount_html[0].to_i if amount_html

      due_at_html = page.search(
        "#outstanding_balance_box_label h5 span"
      ).inner_text.match(/(\d{2})\/(\d{2})\/(\d{2})/)

      due_at = Date.parse("20#{due_at_html[3]}-#{due_at_html[2]}-#{due_at_html[1]}") if due_at_html

      paid = page.search(
        "#payments .bill .desc"
      ).inner_text.downcase.include?("received")

      uid = Digest::MD5.hexdigest("BSkyB#{account_id}")

      @accounts << Squeegee::Account.new(
        name: "Sky (#{account_id.to_s[-4..-1]})",
        amount: amount,
        due_at: due_at,
        paid: paid,
        number: account_id,
        uid: uid
      )

    #rescue NoMethodError => e
      #raise Error::PageMissingContent, "Can't find something on the page"
    end
  end
end
