# Namespace for classes and modules that handle connections to, and processing of data from OpenSearch APIs.
# @since 0.1.0
module Parliament
  module OpenSearch
    # Currently just a namespace definition
    class << self
      def load!
        if parliament_response?
          register_parliament_response
        else
          raise(LoadError, 'Missing requirement Parliament::Response')
        end

        if parliament_request?
          register_parliament_request
        else
          raise(LoadError, 'Missing requirement Parliament::Request')
        end

        if parliament_builder?
          register_parliament_builder
        else
          raise(LoadError, 'Missing requirement Parliament::Builder')
        end

        register_opensearch
        register_rexml_document
        register_active_support_inflector
      end

      def parliament_response?
        defined?(::Parliament::Response)
      end

      def parliament_request?
        defined?(::Parliament::Request)
      end

      def parliament_builder?
        defined?(::Parliament::Builder)
      end

      private

      def register_parliament_response
        require 'parliament/response'
      end

      def register_parliament_request
        require 'parliament/request'
      end

      def register_parliament_builder
        require 'parliament/builder'
      end

      def register_opensearch
        require 'parliament/open_search/version'
        require 'parliament/open_search/description_error'
        require 'parliament/request/open_search_request'
        require 'parliament/builder/open_search_response_builder'
      end

      def register_rexml_document
        require 'rexml/document'
      end

      def register_active_support_inflector
        require 'active_support/inflector'
      end
    end
  end
end

Parliament::OpenSearch.load!
