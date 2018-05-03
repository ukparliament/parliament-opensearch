require_relative '../../../../spec/spec_helper'

describe Parliament::Builder::OpenSearchResponseBuilder, vcr: true do
  let(:request) do
    Parliament::Request::OpenSearchRequest.new(description_url: ENV['OPENSEARCH_DESCRIPTION_URL'],
                                               headers: { 'Accept' => 'application/atom+xml',
                                                          'Ocp-Apim-Subscription-Key' => ENV['OPENSEARCH_AUTH_TOKEN']
                                               },
                                               builder: Parliament::Builder::OpenSearchResponseBuilder)
  end

  context 'build' do
    before(:each) do
      @search_response = request.get({ query: 'banana', start_page: '10' })
    end

    it 'returns a Feedjira::Feed object' do
      expect(@search_response).to be_a(Feedjira::Parser::Atom)
    end

    it 'returns the correct data within the Feedjira Feed' do
      expect(@search_response.entries.first.title).to eq('Trade dispute between the EU and the US over bananas')
      expect(@search_response.entries.first.content).to include('The Trade Dispute between the EU and the USA over Bananas ... “In respect of banana exports to the Community market, no ACP State shall be placed, ...')
      expect(@search_response.entries.first.url).to eq('http://researchbriefings.files.parliament.uk/documents/RP99-28/RP99-28.pdf')
      expect(@search_response.totalResults).to eq('351')
    end

    context 'hints' do
      it 'will return the correct type' do
        expect(@search_response.entries.first.hint_types).to eq(['pdf', 'Research Briefings', 'Research Briefings document', 'Document reference number: RP99-28', 'Research Paper'])
        expect(@search_response.entries.last.hint_types).to eq(['Research Briefings', 'Commons Briefing Paper'])
      end

      it 'will return multiple hints' do
        expect(@search_response.entries.first.hint_types.class).to eq(Array)
      end

      context 'no hints' do
        it 'returns an empty array' do
          expect(@search_response.entries.first.hint_types).to eq([])
        end
      end
    end

    context 'formatted URL' do
      it 'will return the correct title' do
        expect(@search_response.entries[1].formatted_url).to eq('https://hansard.parliament.uk/.../EUTradeAgreementOnBananaImports')
      end
    end
  end
end
