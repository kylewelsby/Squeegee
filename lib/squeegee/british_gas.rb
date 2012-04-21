module Squeegee

  # BritishGas - Energy Supplier
  # * can have more than one account.
  #
  class BritishGas < Base
    HOST = "https://www.britishgas.co.uk"
    LOGIN_URL = "#{HOST}/Your_Account/Account_Details/"
    ACCOUNTS_URL = "#{HOST}/AccountSummary/getAccountDetailsForSummary/"
    ACCOUNT_URL = "#{HOST}/Your_Account/Account_Transaction/"

    attr_accessor :accounts

    FIELD = {
      email: "userName",
      password: "password"
    }

    def initialize(args = {})
      @keys = %w(email password)

      params(args)
      @email = args.delete(:email)
      @password = args.delete(:password)
      @accounts = []

      authenticate!
      get_accounts
    end

    private

    def authenticate!
      page = get(LOGIN_URL)
      form = page.form_with(action: '/Online_User/Account_Summary/')

      form[FIELD[:email]] = @email
      form[FIELD[:password]] = @password

      page = @agent.submit(form, form.buttons.first)
      #raise Error::Unauthorized, "Account details could be wrong" if page.at('.error')
    end

    def get_accounts
      page = get(ACCOUNTS_URL)
      accounts = JSON.parse(page.body)
      #account_ids = page.search("table#tableSelectAccount td > strong").collect {|row| row.content.to_i}
      accounts.each do |account|
        response = get_account(account['accountReferenceNumber'])
        @accounts << Squeegee::Account.new(response)
      end
    end

    def get_account(id)
      response = {}
      url = "#{Squeegee::BritishGas::ACCOUNT_URL}?accountnumber=#{id}"
      page = get(url)
      table = page.search("div#divHistoryTable table tbody")
      rows = table.search("tr").map do |row|
        tds = row.search("td")
        _row = {
          date: Date.parse(
            tds.first.inner_text.match(/\d{2}\s\w{3}\s\d{4}/)[0]
          ),
            type: tds[1].inner_text.match(/[A-Za-z]{2,}\s?[A-Za-z]?{2,}/)[0],
            debit: tds[2].inner_text.to_f,
            credit: tds[3].inner_text.to_f,
            balance: tds[4].inner_text.to_f
        }
        _row
      end
      response[:paid] = !!(rows[0][:balance] = 0)
      rows.each do |row|
        if row[:debit] > 0
          response[:amount] = row[:debit].to_s.gsub(/\.|,/,'').to_i
          response[:due_at] = row[:date]
          break
        end
      end
      response[:uid] = Digest::MD5.hexdigest("BritishGas#{id}")
      response[:name] = "BritishGas (#{id.to_s[-4..-1]})"
      response
    end

  end
end
