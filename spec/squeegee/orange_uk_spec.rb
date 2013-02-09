# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Squeegee::OrangeUK do
  let(:mechanize) {mock('mechanize') }
  let(:node) {mock('node')}
  let(:form) {mock('form')}
  let(:button) {mock('button')}

  subject{Squeegee::OrangeUK}

  context "parameters" do
    before do
      subject.any_instance.stub(:get_statement)
      subject.any_instance.stub(:authenticate!)
    end
    it "raises InvalidParams when username and password is missing" do
      expect{
        subject.new
      }.to raise_error(
        Squeegee::Error::InvalidParams,
        "missing parameters `username` `password` "
      )
    end

    it "accepts email and password" do
      expect{
        subject.new(username: "joe",
                    password: 'superduper')
      }.to_not raise_error
    end
  end

  context "calls" do
    before do
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:get_statement)
      subject.any_instance.stub(:authenticate!)
    end

    it "calls params with arguments" do
      subject.any_instance.should_receive(:params).with({username: "joe"})
      subject.new(username: 'joe')
    end
    it "calls authenticate" do
      subject.any_instance.should_receive(:authenticate!)
      subject.new
    end
    it "calls get_statement" do
      subject.any_instance.should_receive(:get_statement)
      subject.new
    end
  end

  describe "private #authenticate!" do
    before do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)
      mechanize.stub(form_with: form.as_null_object)
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:get_statement)
    end

    it "finds by form action" do
      mechanize.should_receive(:form_with).with(
        action: "/id/signin.php?rm=StandardSubmit"
      ).and_return(form)
      subject.new
    end
    it "fillts in form inputs" do
      form.should_receive(:[]=).with("LOGIN", "joebloggs")
      form.should_receive(:[]=).with('PASSWORD', 'superduper')
      subject.new(username: 'joebloggs', password: 'superduper')
    end
    it "submits form" do
      form.should_receive(:buttons).and_return([button])
      mechanize.should_receive(:submit).with(form,button).and_return(mechanize)
      subject.new
    end
    it "raises unauthenticated if page returns error" do
      mechanize.stub(:submit => mechanize)

      mechanize.should_receive(:uri).and_return("https://web.orange.co.uk/id/signin.php?rm=StandardSubmit")
      mechanize.should_receive(:search).with('.error').and_return("Please enter a valid username and password.")

      expect{
        subject.new
      }.to raise_error(Squeegee::Error::Unauthenticated)
    end
  end

  describe "private #get_statement" do
    before do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
    end

    it "finds the due date" do
      mechanize.should_receive(:search).with(
        "#eBillMainContent .eBillStandardTable"
      ).and_return([node])
      node.should_receive(:search).with("td").twice.and_return(
        [
          stub(:inner_text => "15 May 2012"),
          {},
          stub(:inner_text => "£25.50")
        ]
      )
      mechanize.stub(:at).with('#accountSelectorLilp').and_return({'value' => '1234'})
      Squeegee::Account.should_receive(:new).
        with(amount: 2550,
             name: "Orange UK (1234)",
             uid: "06a0a787d8267fcb1a2887dc7baf4de1",
             :number => 1234,
             due_at: Date.parse('2012-05-15'))
      subject.new
    end

    it "gets a negative number" do
      mechanize.should_receive(:search).with(
        "#eBillMainContent .eBillStandardTable"
      ).and_return([node])
      node.should_receive(:search).with("td").twice.and_return(
        [
          stub(:inner_text => "15 May 2012"),
          {},
          stub(:inner_text => "£-25.50")
        ]
      )
      mechanize.stub(:at).with('#accountSelectorLilp').and_return({'value' => '1234'})
      Squeegee::Account.should_receive(:new).
        with(amount: -2550,
             name: "Orange UK (1234)",
             uid: "06a0a787d8267fcb1a2887dc7baf4de1",
             :number => 1234,
             due_at: Date.parse('2012-05-15'))
      subject.new
    end
  end

end
