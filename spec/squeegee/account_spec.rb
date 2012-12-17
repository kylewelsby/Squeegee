require 'spec_helper'

describe Squeegee::Account do
  let(:attr){{
    name:'',
    uid:'',
    amount:'',
    due_at:''
  }}
  subject {Squeegee::Account}
  it {subject.new(attr).should respond_to(:name)}
  it {subject.new(attr).should respond_to(:amount)}
  it {subject.new(attr).should respond_to(:due_at)}
  it {subject.new(attr).should respond_to(:paid)}

  it "validates presence of name" do
    attr.delete(:name)
    expect{
      subject.new(attr)
    }.to raise_error(Squeegee::Error::InvalidParams, "missing parameters `name` ")
  end

  it "validates presence of amount" do
    attr.delete(:amount)
    expect{
      subject.new(attr)
    }.to raise_error(Squeegee::Error::InvalidParams, "missing parameters `amount` ")
  end

  it "validates presence of uid" do
    attr.delete(:uid)
    expect{
      subject.new(attr)
    }.to raise_error(Squeegee::Error::InvalidParams, "missing parameters `uid` ")
  end

  it "validates presence of due_at" do
    attr.delete(:due_at)
    expect{
      subject.new(attr)
    }.to raise_error(Squeegee::Error::InvalidParams, "missing parameters `due_at` ")
  end
end
