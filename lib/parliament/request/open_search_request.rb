module Parliament
  module Request
    # API request object, allowing the user to build a request to an OpenSearch API and build a response.
    #
    # @since 0.1.0
    class OpenSearchRequest < Parliament::Request::BaseRequest
      OPEN_SEARCH_PARAMETERS = {
          count: 10,
          start_index: 1,
          start_page: 1,
          language: '*',
          output_encoding: 'UTF-8',
          input_encoding: 'UTF-8'
      }.freeze

      # Creates a new instance of Parliament::OpenSearch::Request.
      #
      # An interesting note for #initialize is that setting description_url on the class means you don't need to pass in a description_url.
      # You can pass one anyway to override the class parameter.  Similarly, headers can be set by either settings the headers on the class,
      # or passing headers in.
      #
      # @see Parliament::BaseRequest#initialize
      # @param [String] description_url the url for the OpenSearch API description file. (expected: http://example.com/description.xml - without the trailing slash).
      # @param [Hash] headers the headers being sent in the request.
      # @param [Parliament::OpenSearch::Builder] builder the builder required to create the response.
      def initialize(description_url: nil, headers: nil, builder: nil)
        @description_url = description_url

        raise Parliament::OpenSearch::DescriptionError.new(@description_url), 'No description URL passed to Parliament::OpenSearchRequest#new and, no Parliament::OpenSearchRequest#base_url value set. Without a description URL, we are unable to make any search requests.' if @description_url.nil? && self.class.base_url.nil?

        @base_url = Parliament::Request::OpenSearchRequest.get_description(@description_url) || self.class.base_url
        @open_search_parameters = self.class.open_search_parameters

        super(base_url: @base_url, headers: headers, builder: builder)
      end

      # Sets up the query url using the base_url and parameters, then make an HTTP GET request and process results.
      #
      # @see Parliament::BaseRequest#get
      # @params [Hash] search_params the search parameters to be passed to the OpenSearch API.  This is the search term and/or any of the keys from OPEN_SEARCH_PARAMETERS, depending on the parameters allowed in the API.
      # @params [Hash] params any extra parameters.
      def get(search_params, params: nil)
        setup_query_url(search_params)

        super(params: params)
      end

      private

      # @attr [String] base_url the base url for the OpenSearch API description. (expected: http://example.com - without the trailing slash).
      # @attr [Hash] open_search_parameters the possible parameters to use in the query url.
      class << self
        attr_reader :description_url, :base_url

        def description_url=(description_url)
          @description_url = description_url
          @base_url = Parliament::Request::OpenSearchRequest.get_description(@description_url)
        end

        def open_search_parameters
          OPEN_SEARCH_PARAMETERS.dup
        end

        def get_description(url)
          return if url.nil?

          begin
            URI.parse(url)
          rescue URI::InvalidURIError => e
            raise Parliament::OpenSearch::DescriptionError.new(url), "Invalid description URI passed '#{url}': #{e.message}"
          end

          request = Parliament::Request::BaseRequest.new(base_url: url,
                                                         headers: {'Accept' => 'application/opensearchdescription+xml'})
          xml_response = request.get

          begin
            xml_root = REXML::Document.new(xml_response.body).root
            template = xml_root.elements['Url'].attributes['template']

            raise Parliament::OpenSearch::DescriptionError.new(url), "The document found does not contain a require node. Attempted to get a 'Url' element with the attribute 'template'. Please check the description document at '#{url}' and try again." if template.nil?
          rescue NoMethodError
            raise Parliament::OpenSearch::DescriptionError.new(url), "The document found does not appear to be XML. Please check the description document at '#{url}' and try again."
          end

          template
        end
      end

      def query_url
        @query_url
      end

      def setup_query_url(search_params)
        search_terms = search_params[:query]
        query_url = @base_url.dup
        query_url.gsub!('{searchTerms}', search_terms)

        @open_search_parameters.each do |key, value|
          camel_case_key = ActiveSupport::Inflector.camelize(key.to_s, false)
          if search_params.keys.include?(key)
            query_url.gsub!("{#{camel_case_key}?}", search_params[key].to_s)
          else
            query_url.gsub!("{#{camel_case_key}?}", value.to_s)
          end
        end

        @query_url = query_url
      end
    end
  end
end
