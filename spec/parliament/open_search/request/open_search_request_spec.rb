require_relative '../../../../spec/spec_helper'

describe Parliament::Request::OpenSearchRequest, vcr: true do
  context 'initializing' do
    context 'with @templates set in the #initialize method' do
      it 'sets @templates correctly when passed the description_url' do
        request = Parliament::Request::OpenSearchRequest.new(description_url: 'https://api20170418155059.azure-api.net/search/description')

        expect(request.templates).to eq({ url: [{ type: 'application/atom+xml',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'application/rss+xml',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'application/json',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'text/json',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'text/xml',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'application/xml',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' }] })
      end
    end

    context 'with description_url set on the class' do
      it 'sets @description_url and @templates correctly when set on the class' do
        Parliament::Request::OpenSearchRequest.description_url = 'https://api20170418155059.azure-api.net/search/description'
        request = Parliament::Request::OpenSearchRequest.new

        expect(Parliament::Request::OpenSearchRequest.description_url).to eq('https://api20170418155059.azure-api.net/search/description')
        expect(request.templates).to eq({ url: [{ type: 'application/atom+xml',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'application/rss+xml',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'application/json',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'text/json',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'text/xml',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' },
                                                { type: 'application/xml',
                                                  template: 'https://api20170418155059.azure-api.net/search?q={searchTerms}&start={startPage?}&pagesize={count?}' }] })
      end

      it 'raises a Parliament::OpenSearch::DescriptionError if the description_url is an invalid format' do
        expect { Parliament::Request::OpenSearchRequest.description_url = 'not a valid URI!' }.to raise_error(Parliament::OpenSearch::DescriptionError, "Invalid description URI passed 'not a valid URI!': bad URI(is not URI?): not a valid URI!")
      end

      it 'raises a Parliament::OpenSearch::DescriptionError if the description_url is not set on the class, or in the initializer' do
        Parliament::Request::OpenSearchRequest.description_url = nil

        expect{ Parliament::Request::OpenSearchRequest.new().base_url }.to raise_error(Parliament::OpenSearch::DescriptionError, 'No description URL passed to Parliament::OpenSearchRequest#new and, no Parliament::OpenSearchRequest#base_url value set. Without a description URL, we are unable to make any search requests.')
      end
    end

    context 'with an invalid description document' do
      it 'raises a Parliament::OpenSearch::DescriptionError for non-xml' do
        expect{ Parliament::Request::OpenSearchRequest.new(description_url: 'http://parliament-search-api.azurewebsites.net/description.json') }.to raise_error(Parliament::OpenSearch::DescriptionError, "The document found does not appear to be XML. Please check the description document at 'http://parliament-search-api.azurewebsites.net/description.json' and try again.")
      end

      it 'raises a Parliament::OpenSearch::DescriptionError for xml missing required nodes' do
        expect{ Parliament::Request::OpenSearchRequest.new(description_url: 'http://parliament-search-api.azurewebsites.net/description') }.to raise_error(Parliament::OpenSearch::DescriptionError, "The document found does not contain the required node. Attempted to get a 'Url' element with the attribute 'template'. Please check the description document at 'http://parliament-search-api.azurewebsites.net/description' and try again.")
      end
    end
  end

  context '#get' do
    before(:each) do
      @request = Parliament::Request::OpenSearchRequest.new(description_url: 'https://api20170418155059.azure-api.net/search/description',
                                                            headers: { 'Accept' => 'application/atom+xml',
                                                                       'Ocp-Apim-Subscription-Key' => ENV['OPENSEARCH_AUTH_TOKEN']},
                                                            builder: Parliament::Builder::OpenSearchResponseBuilder)
    end

    it 'returns a Feedjira Feed' do
      result = @request.get({ query: 'apple', start_page: '10' })

      expect(result).to be_a(Feedjira::Parser::Atom)
    end

    it 'returns the correct data within the Feedjira Feed' do
      result = @request.get({ query: 'banana', start_page: '10' })

      expect(result.entries.first.title).to eq('House of Commons Standing Committee (pt 4)')
      expect(result.entries.first.summary).to include('I do not want to repeat all the elegant and witty remarks I made on the importance <br>
of the <b>banana</b> in my life')
      expect(result.entries.first.url).to eq('http://www.publications.parliament.uk/pa/cm199900/cmstand/euroa/st000404/00404s04.htm')
      expect(result.totalResults).to eq('18900')
    end

    it 'sets the search parameters correctly - uses the defaults' do
      @request.get({ query: 'orange' })

      expect(WebMock).to have_requested(:get, 'https://api20170418155059.azure-api.net/search?pagesize=10&q=orange&start=1').once
    end

    it 'sets the search parameters correctly - uses the parameters passed in' do
      @request.get({ query: 'cherry', start_page: '20' })

      expect(WebMock).to have_requested(:get, 'https://api20170418155059.azure-api.net/search?pagesize=10&q=cherry&start=20').once
    end

    it 'can accept a type and make a request to the correct url using the specified type' do
      new_request = Parliament::Request::OpenSearchRequest.new(description_url: 'https://api20170418155059.azure-api.net/search/description',
                                                               headers: { 'Accept' => 'application/rss+xml',
                                                                          'Ocp-Apim-Subscription-Key' => ENV['OPENSEARCH_AUTH_TOKEN']
                                                               },
                                                               builder: Parliament::Builder::OpenSearchResponseBuilder)
      new_request.get({ query: 'peach' }, type: 'application/rss+xml')

      expect(WebMock).to have_requested(:get, 'https://api20170418155059.azure-api.net/search?pagesize=10&q=peach&start=1').
          with(:headers => {'Accept'=>['*/*', 'application/rss+xml']}).once
    end

    it 'raises an error if the requested type is not specified in the description document' do
      error_request = Parliament::Request::OpenSearchRequest.new(description_url: 'https://api20170418155059.azure-api.net/search/description',
                                                               headers: { 'Accept' => 'application/rss+xml',
                                                                          'Ocp-Apim-Subscription-Key' => ENV['OPENSEARCH_AUTH_TOKEN']
                                                               },
                                                               builder: Parliament::Builder::OpenSearchResponseBuilder)
      expect{ error_request.get({ query: 'peach' }, type: 'application/ntriple') }.to raise_error(Parliament::OpenSearch::DescriptionError, "There is no url for the requested type 'application/ntriple'.")
    end
  end
end
