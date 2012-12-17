require 'spec_helper'

describe Squeegee::Base do
  describe "#params" do
    it "should raise InvalidParams if any parameters are missing" do
      expect{
        subject.keys = ['test']
        subject.params({})
      }.to raise_error(Squeegee::Error::InvalidParams, "missing parameters `test` ")
    end

    it "should raise error if no arguments given" do
      expect{
        subject.params
      }.to raise_error(ArgumentError, "wrong number of arguments (0 for 1)")
    end

    it "should return nil if keys are not defined" do
      subject.params({}).should be_nil
    end
  end

  describe "#get" do
    let(:mechanize) {mock('mechanize')}
    let(:logger) {mock('logger')}
    it "should assign agent with a new instance of Mechanize" do
      Mechanize.should_receive(:new).and_return(mechanize)

      mechanize.should_receive(:user_agent=).with("Mozilla/5.0 (Squeegee)")
      mechanize.should_receive(:default_encoding=).with("utf8")
      Logger.should_receive(:new).with('squeegee.log').and_return(logger)
      mechanize.should_receive(:log=).with(logger)
      mechanize.should_receive(:get).with("http://google.com")
      agent = stub(:agent)
      mechanize.should_receive(:agent).and_return(agent)
      http = stub(:http)
      agent.should_receive(:http).and_return(http)
      http.should_receive(:ssl_version=).with(:SSLv3)

      subject.get("http://google.com")
    end
  end
end
