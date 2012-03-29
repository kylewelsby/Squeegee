require 'spec_helper'

describe Squeegee::BritishGas do
  let(:mechanize) {mock('mechanize') }
  let(:node) {mock('node')}
  let(:form) {mock('form')}
  let(:button) {mock('button')}

  subject {Squeegee::BritishGas}

  context "classes" do
    before do
      Mechanize.any_instance.stub(get: mechanize)
    end
    subject {Squeegee::BritishGas::Account.new(1, mechanize.as_null_object)}
    it "should get single account" do
      pending
      Mechanize.any_instance.should_receive(:get).at_least(:once).with(
        "https://www.britishgas.co.uk/Your_Account/Account_Transaction/?accountnumber=1"
      ).and_return(mechanize.as_null_object)

      subject
    end
    it "should build array of data" do
      mechanize.should_receive(:search).with(
        "div#divHistoryTable table tbody"
      ).and_return(node)

      node.should_receive(:search).with("tr").and_return([node])
      node.should_receive(:search).with("td").and_return(
        [
          stub(inner_text: "12 Feb 2012"),
          stub(inner_text: "Payment Received"),
          stub(inner_text: ""),
          stub(inner_text: "30.50"),
          stub(inner_text: "0.00")
        ]
      )

      subject.paid.should be_true
    end
  end

  context "Parameters" do
    before do
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:get_statements)
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
    before do
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:get_statements)
    end

    it "calls authenticate!" do
      subject.any_instance.should_receive(:authenticate!)
      subject.new
    end

    it "calls get_accounts" do
      subject.any_instance.should_receive(:get_statements)
      subject.new
    end

    it "calls params with arguments" do
      args = {:a => 'b'}
      subject.any_instance.should_receive(:params).with(args)
      subject.new(args)
    end
  end

  context "Authentication" do
    before do
      subject.any_instance.stub(:params)
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

  context "get_accounts" do
    before do
      subject.any_instance.stub(:params)
      Mechanize.any_instance.stub(get: mechanize)
      subject.any_instance.stub(:authenticate!)
      mechanize.stub(search: [stub(content: "  1  ")])
      subject::Account.stub(:new, mechanize)
    end

    it "navigates to account list URL" do
      Mechanize.any_instance.should_receive(:get).with(
        "https://www.britishgas.co.uk/Account_History/Transactions_Account_List/"
      ).and_return(mechanize)
      subject.new
    end

    it "initialises a new account" do
      pending
      #mechanize.stub(search: [stub(content: "  1  ")])
      #subject::Account.should_receive(:new).with(1, Mechanize.new())
      #subject.new
    end
  end
end
