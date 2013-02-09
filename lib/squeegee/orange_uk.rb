module Squeegee

  # OrangeUK - Mobile network
  #
  class OrangeUK < Base
    LOGIN_URL = "https://web.orange.co.uk/r/login/"
    BILLS_URL = "https://www.youraccount.orange.co.uk/sss/jfn?mfunc=63&jfnRC=1"
    LOGIN_POST_URL = "https://web.orange.co.uk/id/signin.php?rm=StandardSubmit"

    FIELD = {
      username: 'LOGIN',
      password: 'PASSWORD'
    }

    attr_accessor :accounts, :account_id, :paid, :amount, :due_at

    def initialize(args = {})
      @keys = %w(username password)
      @accounts = []

      @agent = Mechanize.new

      # NOTE: Orange websites redirects though insecure servers.
      @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      params(args)
      @username = args.delete(:username)
      @password = args.delete(:password)

      authenticate!
      get_statement
    end

    private

    def authenticate!
      page = get(LOGIN_URL)
      form = page.form_with(action: '/id/signin.php?rm=StandardSubmit')

      form[FIELD[:username]] = @username
      form[FIELD[:password]] = @password

      page = @agent.submit(form, form.buttons.first)

      if page.uri.to_s == LOGIN_POST_URL && !page.search('.error').nil?
        raise Squeegee::Error::Unauthenticated
      end
    end

    def get_statement

      page = get(BILLS_URL)

      last_bill = page.search("#eBillMainContent .eBillStandardTable").first

      balance = page.search("#paymBalanceIncVAT").inner_text.gsub(/\.|,/,'').match(/\d{1,}/)

      due_at = Date.parse(last_bill.search("td")[0].inner_text)
      amount = last_bill.search('td')[2].inner_text.gsub(/\.|,/,'').match(/\-?\d{1,}/)[0].to_i
      number = page.at("#accountSelectorLilp")['value'].to_i
      #@paid = balance || balance[0].to_i >= 0
      uid = Digest::MD5.hexdigest("OrangeUK#{number}")

      @accounts << Squeegee::Account.new(due_at: due_at,
                                         name: "Orange UK (#{number.to_s[-4..-1]})",
                                         uid: uid,
                                         number: number,
                                         amount: amount)
    end
  end
end
