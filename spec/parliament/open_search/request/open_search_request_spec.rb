require_relative '../../../../spec/spec_helper'

describe Parliament::Request::OpenSearchRequest, vcr: true do
  context 'initializing' do
    context 'with @base_url set in the #initialize method' do
      it 'sets @base_url correctly when passed in' do
        request = Parliament::Request::OpenSearchRequest.new(description_url: 'http://parliament-search-api.azurewebsites.net/description')

        expect(request.base_url).to eq('http://parliament-search-api.azurewebsites.net/search?q={searchTerms}&start={startPage?}')
      end
    end

    context 'with @base_url set on the class' do
      it 'sets @description_url and @base_url correctly when set on the class' do
        Parliament::Request::OpenSearchRequest.description_url = 'http://parliament-search-api.azurewebsites.net/description'
        request = Parliament::Request::OpenSearchRequest.new

        expect(Parliament::Request::OpenSearchRequest.description_url).to eq('http://parliament-search-api.azurewebsites.net/description')
        expect(request.base_url).to eq('http://parliament-search-api.azurewebsites.net/search?q={searchTerms}&start={startPage?}')
      end

      it 'raises a Parliament::OpenSearch::DescriptionError if the base_url is an invalid format' do
        expect { Parliament::Request::OpenSearchRequest.description_url = 'not a valid URI!' }.to raise_error(Parliament::OpenSearch::DescriptionError, "Invalid description URI passed 'not a valid URI!': bad URI(is not URI?): not a valid URI!")
      end

      it 'raises a Parliament::OpenSearch::DescriptionError if the base_url is not set on the class, or in the initializer' do
        Parliament::Request::OpenSearchRequest.description_url = nil
        expect{ Parliament::Request::OpenSearchRequest.new().base_url }.to raise_error(Parliament::OpenSearch::DescriptionError, 'No description URL passed to Parliament::OpenSearchRequest#new and, no Parliament::OpenSearchRequest#base_url value set. Without a description URL, we are unable to make any search requests.')
      end
    end

    context 'with an invalid description document' do
      it 'raises a Parliament::OpenSearch::DescriptionError for non-xml' do
        expect{ Parliament::Request::OpenSearchRequest.new(description_url: 'http://parliament-search-api.azurewebsites.net/description.json') }.to raise_error(Parliament::OpenSearch::DescriptionError, "The document found does not appear to be XML. Please check the description document at 'http://parliament-search-api.azurewebsites.net/description.json' and try again.")
      end

      it 'raises a Parliament::OpenSearch::DescriptionError for xml missing required nodes' do
        expect{ Parliament::Request::OpenSearchRequest.new(description_url: 'http://parliament-search-api.azurewebsites.net/description') }.to raise_error(Parliament::OpenSearch::DescriptionError, "The document found does not contain a require node. Attempted to get a 'Url' element with the attribute 'template'. Please check the description document at 'http://parliament-search-api.azurewebsites.net/description' and try again.")
      end
    end
  end

  context '#get' do
    before(:each) do
      @request = Parliament::Request::OpenSearchRequest.new(description_url: 'http://parliament-search-api.azurewebsites.net/description',
                                                            headers: { 'Accept' => 'application/atom+xml' },
                                                            builder: Parliament::Builder::OpenSearchResponseBuilder)
    end

    it 'returns a Feedjira Feed' do
      result = @request.get({ query: 'banana', start_page: '10' })

      expect(result).to be_a(Feedjira::Parser::Atom)
    end

    it 'returns the correct data within the Feedjira Feed' do
      result = @request.get({ query: 'banana', start_page: '10' })

      expect(result.entries.first.title).to eq('House of Commons - Documents considered by the Committee on ...')
      expect(result.entries.first.summary).to include('Dec 15, 2010 <b>...</b> 9.3 In that chapter, we also outlined the steps that the EU had taken')
      expect(result.entries.first.url).to eq('https://www.publications.parliament.uk/pa/cm201011/cmselect/cmeuleg/428/42811.htm')
      expect(result.totalResults).to eq('18400')
    end

    it 'sets the search parameters correctly - uses the defaults' do
      @request.get({ query: 'banana' })

      expect(WebMock).to have_requested(:get, 'http://parliament-search-api.azurewebsites.net/search?q=banana&start=1').
          with(:headers => {'Accept'=>['*/*', 'application/atom+xml'], 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).once
    end

    it 'sets the search parameters correctly - uses the parameters passed in' do
      @request.get({ query: 'banana', start_page: '20' })

      expect(WebMock).to have_requested(:get, 'http://parliament-search-api.azurewebsites.net/search?q=banana&start=20').
          with(:headers => {'Accept'=>['*/*', 'application/atom+xml'], 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).once
    end
  end
end
