require_relative '../../../../spec/spec_helper'

describe Parliament::Request::OpenSearchRequest, vcr: true do
  context 'initializing' do
    context 'with no headers passed' do
      original_env = nil

      before :each do
        original_env = ENV
        ENV['OPENSEARCH_AUTH_TOKEN'] = 'abc123'
        ENV['PARLIAMENT_API_VERSION'] = 'Staging'
      end

      after :each do
        ENV = original_env
      end

      it 'starts with default headers' do
        expect(Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/search/description').headers).to eq({ "Accept" => 'application/atom+xml', "Ocp-Apim-Subscription-Key" => 'abc123', "Api-Version" => 'Staging' })
      end

      context 'without optional environment variables=' do
        original_env = nil

        before :each do
          original_env = ENV
          ENV.delete('OPENSEARCH_AUTH_TOKEN')
          ENV.delete('PARLIAMENT_API_VERSION')
        end

        after :each do
          ENV = original_env
        end

        it 'starts with limited default headers' do
          expect(Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/search/description').headers).to eq({ "Accept" => 'application/atom+xml' })
        end
      end
    end

    context 'with headers passed' do
      original_env = nil

      before :each do
        original_env = ENV
        ENV['OPENSEARCH_AUTH_TOKEN'] = 'abc123'
        ENV['PARLIAMENT_API_VERSION'] = 'Staging'
      end

      after :each do
        ENV = original_env
      end

      it 'overwrites default values' do
        expect(Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/search/description', headers: { "Accept" => 'Foo', "Ocp-Apim-Subscription-Key" => 'Bar', "Api-Version" => 'Baz' }).headers).to eq({ "Accept" => 'Foo', "Ocp-Apim-Subscription-Key" => 'Bar', "Api-Version" => 'Baz' })
      end
    end

    context 'with @templates set in the #initialize method' do
      it 'sets @templates correctly when passed the description_url' do
        request = Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/Staging/search/description')

        expect(request.templates).to eq([
          { type: 'application/atom+xml',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'application/rss+xml',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'application/json',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'text/json',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'text/xml',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'application/xml',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' }
        ])
      end
    end

    context 'with description_url set on the class' do
      it 'sets @description_url and @templates correctly when set on the class' do
        Parliament::Request::OpenSearchRequest.configure_description_url('https://api.parliament.uk/Staging/search/description')
        request = Parliament::Request::OpenSearchRequest.new

        expect(request.description_url).to eq('https://api.parliament.uk/Staging/search/description')
        expect(request.templates).to eq([
          { type: 'application/atom+xml',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'application/rss+xml',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'application/json',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'text/json',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'text/xml',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' },
          { type: 'application/xml',
            template: 'https://api-parliament-uk.azure-api.net/Staging/search?q={searchTerms}&start={startIndex?}&count={count?}' }
        ])
      end

      it 'raises a Parliament::OpenSearch::DescriptionError if the description_url is an invalid format' do
        expect { Parliament::Request::OpenSearchRequest.configure_description_url('not a valid URI!') }.to raise_error(Parliament::OpenSearch::DescriptionError, "Invalid description URI passed 'not a valid URI!': bad URI(is not URI?): not a valid URI!")
      end

      it 'raises a Parliament::OpenSearch::DescriptionError if the description_url is not set on the class, or in the initializer' do
        Parliament::Request::OpenSearchRequest.configure_description_url(nil)

        expect{ Parliament::Request::OpenSearchRequest.new().base_url }.to raise_error(Parliament::OpenSearch::DescriptionError, 'No description URL passed to Parliament::OpenSearchRequest#new and, no Parliament::OpenSearchRequest#base_url value set. Without a description URL, we are unable to make any search requests.')
      end
    end

    context 'with an invalid description document' do
      it 'raises a Parliament::OpenSearch::DescriptionError for non-xml' do
        expect{ Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/Staging/search/description') }.to raise_error(Parliament::OpenSearch::DescriptionError, "The document found does not appear to be XML. Please check the description document at 'https://api.parliament.uk/Staging/search/description' and try again.")
      end

      it 'raises a Parliament::OpenSearch::DescriptionError for xml missing required nodes' do
        expect{ Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/Staging/search/description') }.to raise_error(Parliament::OpenSearch::DescriptionError, "The document found does not contain the required node. Attempted to get a 'Url' element with the attribute 'template'. Please check the description document at 'https://api.parliament.uk/Staging/search/description' and try again.")
      end
    end
  end

  context '#get' do
    before(:each) do
      @request = Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/Staging/search/description',
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

      expect(result.entries.first.title).to eq('Trade dispute between the EU and the US over bananas')
      expect(result.entries.first.content).to include('The Trade Dispute between the EU and the USA over Bananas ... “In respect of banana exports to the Community market, no ACP State shall be placed, ...')
      expect(result.entries.first.url).to eq('http://researchbriefings.files.parliament.uk/documents/RP99-28/RP99-28.pdf')
      expect(result.totalResults).to eq('354')
    end

    it 'sets the search parameters correctly - uses the defaults' do
      @request.get({ query: 'orange' })

      expect(WebMock).to have_requested(:get, 'https://api-parliament-uk.azure-api.net/Staging/search?count=10&q=orange&start=1').once
    end

    it 'sets the search parameters correctly - uses the parameters passed in' do
      @request.get({ query: 'cherry', start_page: '20' })

      expect(WebMock).to have_requested(:get, 'https://api-parliament-uk.azure-api.net/Staging/search?count=10&q=cherry&start=1').once
    end

    it 'can accept a type and make a request to the correct url using the specified type' do
      new_request = Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/Staging/search/description',
                                                               headers: { 'Accept' => 'application/rss+xml',
                                                                          'Ocp-Apim-Subscription-Key' => ENV['OPENSEARCH_AUTH_TOKEN']
                                                               },
                                                               builder: Parliament::Builder::OpenSearchResponseBuilder)
      new_request.get({ query: 'peach' }, type: 'application/rss+xml')

      expect(WebMock).to have_requested(:get, 'https://api-parliament-uk.azure-api.net/Staging/search?count=10&q=peach&start=1').
          with(:headers => {'Accept'=>['*/*', 'application/rss+xml']}).once
    end

    it 'raises an error if the requested type is not specified in the description document' do
      error_request = Parliament::Request::OpenSearchRequest.new(description_url: 'https://api.parliament.uk/Staging/search/description',
                                                               headers: { 'Accept' => 'application/rss+xml',
                                                                          'Ocp-Apim-Subscription-Key' => ENV['OPENSEARCH_AUTH_TOKEN']
                                                               },
                                                               builder: Parliament::Builder::OpenSearchResponseBuilder)
      expect{ error_request.get({ query: 'peach' }, type: 'application/ntriple') }.to raise_error(Parliament::OpenSearch::DescriptionError, "There is no url for the requested type 'application/ntriple'.")
    end
  end
end
