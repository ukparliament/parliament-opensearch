require_relative '../spec_helper'

RSpec.describe Parliament::OpenSearch do
  describe '.load!' do
    context 'without parliament-ruby loaded' do
      context 'without Parliament::Request' do
        before :each do
          allow(Parliament::OpenSearch).to receive(:parliament_request?).and_return(false)
        end

        it 'raises a LoadError' do
          expect{ Parliament::OpenSearch.load! }.to raise_error(LoadError, "Missing requirement 'Parliament::Request'. Have you added `gem 'parliament-ruby'` to your Gemfile?")
        end
      end

      context 'without Parliament::Response' do
        before :each do
          allow(Parliament::OpenSearch).to receive(:parliament_response?).and_return(false)
        end

        it 'raises a LoadError' do
          expect{ Parliament::OpenSearch.load! }.to raise_error(LoadError, "Missing requirement 'Parliament::Response'. Have you added `gem 'parliament-ruby'` to your Gemfile?")
        end
      end

      context 'without Parliament::Builder' do
        before :each do
          allow(Parliament::OpenSearch).to receive(:parliament_builder?).and_return(false)
        end

        it 'raises a LoadError' do
          expect{ Parliament::OpenSearch.load! }.to raise_error(LoadError, "Missing requirement 'Parliament::Builder'. Have you added `gem 'parliament-ruby'` to your Gemfile?")
        end
      end
    end
  end
end