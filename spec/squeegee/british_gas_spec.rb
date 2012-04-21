require 'spec_helper'

describe Squeegee::BritishGas do
  let(:mechanize) {mock('mechanize') }
  let(:node) {mock('node')}
  let(:form) {mock('form')}
  let(:button) {mock('button')}
  let(:json) {[
            {
              'accountReferenceNumber' => 850046061940,
              'Amount' => 70.00,
              'Paymenttype' => ""
            }
          ].to_json}

  subject {Squeegee::BritishGas}

    before do
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:get_accounts)

      Mechanize.stub(:new => mechanize.as_null_object)
      mechanize.stub(:get => mechanize)

    end


  context "Parameters" do
    before do
      subject.any_instance.unstub(:params)
    end
    it "raises InvalidParams when email is missing" do
      expect{
        subject.new
      }.to raise_error(Squeegee::Error::InvalidParams, 
                       "missing parameters `email` `password` ")
    end

    it "raises InvalidParams when password is missing" do
      expect{
        subject.new(email: "test@test.com")
      }.to raise_error(Squeegee::Error::InvalidParams, 
                       "missing parameters `password` ")
    end

    it "accepts email" do
      expect{
        subject.new(email: "test@test.com", password: "superduper")
      }.to_not raise_error
    end
  end

  context "calls" do
    it "calls authenticate!" do
      subject.any_instance.should_receive(:authenticate!)
      subject.new
    end

    it "calls get_accounts" do
      subject.any_instance.should_receive(:get_accounts)
      subject.new
    end

    it "calls params with arguments" do
      args = {:a => 'b'}
      subject.any_instance.should_receive(:params).with(args)
      subject.new(args)
    end
  end

  context "Private" do
    describe "authenticate!" do
      before do
        subject.any_instance.unstub(:authenticate!)
        #subject.any_instance.stub(get: mechanize.as_null_object)
        #Mechanize.any_instance.stub(get: mechanize.as_null_object)
        Mechanize.should_receive(:new).and_return(mechanize.as_null_object)
        mechanize.stub(form_with: form.as_null_object)
      end
      it "navigates to login URL" do
        mechanize.should_receive(:get).with(
          "https://www.britishgas.co.uk/Your_Account/Account_Details/"
        ).and_return(mechanize)

        subject.new({})
      end

      it "finds by form action" do
        mechanize.should_receive(:form_with).with(
          action: '/Online_User/Account_Summary/'
        ).and_return(form.as_null_object)

        subject.new
      end

      it "fills in form inputs" do
        form.should_receive(:[]=).with('userName', 'test@test.com')
        form.should_receive(:[]=).with('password', 'superduper')

        subject.new(email: "test@test.com", password: "superduper")
      end

      it "submits with first button" do
        form.should_receive(:buttons).and_return([button])
        mechanize.should_receive(:submit).with(form, button)

        subject.new(email: "test")
      end
    end

    describe "get_accounts" do
      before do
        subject.any_instance.unstub(:get_accounts)
        subject.any_instance.stub(:get_account)
        Squeegee::Account.stub(:new)
      end
      it "finds account ID's" do
        mechanize.should_receive(:body).and_return(json)
        subject.any_instance.should_receive(:get_account).
          with(850046061940)
        subject.new
      end
    end

    describe "get_account" do
      let(:row) {stub(:row)}
      let(:column) {stub(:column)}
      before do
        subject.any_instance.unstub(:get_accounts)
        #subject.any_instance.unstub(:get_account)
        mechanize.stub(:body).and_return(json)
        mechanize.stub(:search).and_return(stub.as_null_object)
        row.stub(:search).and_return(stub.as_null_object)
        Squeegee::Account.stub(:new)
      end

      it "finds paid bill" do
        mechanize.should_receive(:search).
          with("div#divHistoryTable table tbody").
          and_return(node)
        node.should_receive(:search).
          with('tr').
          and_return([row])
        row.should_receive(:search).
          with('td').
          and_return([
            stub(inner_text: "12 Jun 2012"),
            stub(inner_text: "Payment Received"),
            stub(inner_text: "0.00"),
            stub(inner_text: "10.00"),
            stub(inner_text: "0.00")
          ])
        subject.new
      end

      it "finds debt" do
        mechanize.should_receive(:search).
          with("div#divHistoryTable table tbody").
          and_return(node)
        node.should_receive(:search).
          with('tr').
          and_return([row])
        row.should_receive(:search).
          with('td').
          and_return([
            stub(inner_text: "12 Jun 2012"),
            stub(inner_text: "Debt"),
            stub(inner_text: "20.00"),
            stub(inner_text: "0.00"),
            stub(inner_text: "20.00")
          ])
        subject.new
      end

    end
  end
end
