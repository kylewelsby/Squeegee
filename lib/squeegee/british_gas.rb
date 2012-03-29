module Squeegee

  # BritishGas - Energy Supplier
  # * can have more than one account.
  #
  class BritishGas < Base
    HOST = "https://www.britishgas.co.uk"
    LOGIN_URL = "#{HOST}/Your_Account/Account_Details/"
    ACCOUNTS_URL = "#{HOST}/Account_History/Transactions_Account_List/"
    ACCOUNT_URL = "#{HOST}/Your_Account/Account_Transaction/"

    # British Gas Account information Extration
    # Example:
    #     BritishGas::Account("8500", Mecanize.new)
    #
    class Account < BritishGas
      attr_accessor :paid, :due_at, :amount

      def initialize(id, agent)
        @agent = agent
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
        @paid = !!(rows[0][:balance] = 0)
        rows.each do |row|
          if row[:debit] > 0
            @amount = row[:debit].to_s.gsub(/\.|,/,'').to_i
            @due_at = row[:date]
            break
          end
        end
      end
    end

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

      authenticate!
      get_statements
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

    def get_statements
      page = get(ACCOUNTS_URL)
      account_ids = page.search("table#tableSelectAccount td > strong").collect {|row| row.content.to_i}
      @accounts = account_ids.map do |account_id|
        Account.new(account_id, @agent)
      end
    end

  end
end
