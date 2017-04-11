module Parliament
  module OpenSearch
    # An error raised when there is an issue processing an OpenSearch description file.
    # This could be raised when the URL provided is invalid, or when we are unable to find a URL template for future requests.
    #
    # @attr_reader url the description url that caused the Parliament::OpenSearchDescriptionError.
    #
    # @since 0.2.3
    class DescriptionError < StandardError
      attr_reader :url

      # @param [String] description_url the description url that caused the Parliament::OpenSearchDescriptionError.
      def initialize(description_url)
        @url = description_url
      end
    end
  end
end
