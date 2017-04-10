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
      # An interesting note for #initialize is that setting base_url on the class, or using the environment variable
      # OPENSEARCH_DESCRIPTION_URL means you don't need to pass in a base_url. You can pass one anyway to override the
      # environment variable or class parameter.  Similarly, headers can be set by either settings the headers on the class, or passing headers in.
      #
      # @see Parliament::BaseRequest#initialize
      # @param [String] base_url the base url for the OpenSearch API description. (expected: http://example.com - without the trailing slash).
      # @param [Hash] headers the headers being sent in the request.
      # @param [Parliament::OpenSearch::Builder] builder the builder required to create the response.
      def initialize(base_url: nil, headers: nil, builder: nil)
        @base_url = Parliament::Request::OpenSearchRequest.get_description(base_url) || self.class.base_url || ENV['OPENSEARCH_DESCRIPTION_URL']
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
        attr_reader :base_url, :open_search_parameters

        def base_url=(base_url)
          @base_url = get_description(base_url)
        end

        def open_search_parameters
          OPEN_SEARCH_PARAMETERS.dup
        end

        def get_description(url)
          return if url.nil?

          request = Parliament::Request::BaseRequest.new(base_url: url,
                                                         headers: {'Accept' => 'application/opensearchdescription+xml'})
          xml_response = request.get

          xml_root = REXML::Document.new(xml_response.body).root
          xml_root.elements['Url'].attributes['template']
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
