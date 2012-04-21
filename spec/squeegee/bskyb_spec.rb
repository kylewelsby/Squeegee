# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Squeegee::BSkyB do
  let(:mechanize) {mock('mechanize') }
  let(:node) {mock('node')}
  let(:form) {mock('form')}
  let(:button) {mock('button')}

  subject{Squeegee::BSkyB}

  context "Parameters" do
    before do
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:get_statement)
    end

    it "raises InvalidParams when username is missing" do
      expect{
        subject.new
      }.to raise_error(Squeegee::Error::InvalidParams, "missing parameters `username` `password` ")
    end

    it "raises InvalidParams when password is missing" do
      expect{
        subject.new(username: "joebloggs")
      }.to raise_error(Squeegee::Error::InvalidParams, "missing parameters `password` ")
    end

    it "accepts email and password" do
      expect{
        subject.new(username: "joeblogges",
                    password: "superduper")

      }.to_not raise_error
    end
  end

  context "calls" do
    before do
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
      subject.any_instance.stub(:get_statement)
    end

    it "calls authenticate!" do
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
    it "finds by form name" do
      mechanize.should_receive(:form_with).with(name: "signinform").and_return(form)
      subject.new
    end
    it "fills in form inputs" do
      form.should_receive(:[]=).with("username", "joebloggs")
      form.should_receive(:[]=).with('password', 'superduper')
      subject.new(username: 'joebloggs', password: 'superduper')
    end
    it "submits form" do
      form.should_receive(:buttons).and_return([button])
      mechanize.should_receive(:submit).with(form, button)
      subject.new
    end
  end

  describe "private #get_statement" do
    before do
      Mechanize.stub(:new).and_return(mechanize.as_null_object)
      subject.any_instance.stub(:params)
      subject.any_instance.stub(:authenticate!)
    end
    it "finds the outstanding balance" do
      mechanize.should_receive(:search).with(
        "#outstanding_balance_total span.money-left"
      ).and_return(node)
      mechanize.should_receive(:search).with(
        "#account_management_nav .account-number"
      ).and_return(stub(:inner_text => "Account Number: 85000"))
      node.should_receive(:inner_text).and_return("£65.32")
      subject.new
    end
    it "finds the balance due date" do
      mechanize.stub(:search => stub.as_null_object)
      mechanize.should_receive(:search).with(
        "#outstanding_balance_box_label h5 span"
      ).and_return(node)
      node.should_receive(:inner_text).and_return("Payment due \r\n 13/03/12")
      subject.new
    end
    it "finds the payment received" do
      mechanize.stub(:search => stub.as_null_object)

      mechanize.should_receive(:search).with(
        '#payments .bill .desc'
      ).and_return(node)
      node.should_receive(:inner_text).and_return("Payment Received")

      subject.new
    end

    it "raises PageMissingContent error when something is not correct" do
      pending "not implemented missing content rescue"
      mechanize.should_receive(:search).and_raise(NoMethodError)
      expect{
        subject.new
      }.to raise_error(Squeegee::Error::PageMissingContent)
    end
  end
end
