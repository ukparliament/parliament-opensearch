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
      expect(@search_response.entries.first.title).to eq('House of Commons - Documents considered by the Committee on ...')
      expect(@search_response.entries.first.summary).to include('Dec 15, 2010 <b>...</b> 9.3 In that chapter, we also outlined the steps that the EU had taken')
      expect(@search_response.entries.first.url).to eq('https://www.publications.parliament.uk/pa/cm201011/cmselect/cmeuleg/428/42811.htm')
      expect(@search_response.totalResults).to eq('18600')
    end

    context 'hints' do
      it 'will return the correct type' do
        expect(@search_response.entries.first.hint_type).to eq('Type: PDF')
        expect(@search_response.entries.last.hint_type).to eq('Research Briefings')
      end
    end
  end
end
