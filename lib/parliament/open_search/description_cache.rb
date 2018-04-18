module Parliament
  module OpenSearch
    # A module used to download, cache and serve description files for our OpenSearch requests.
    # @since 0.1
    module DescriptionCache
      DESCRIPTION_CACHE_TIME = 600 # 10 minutes

      class << self
        # Given a description uri, either download the file or serve it from our cache
        #
        # @param [String] uri the uri of our description file
        # @return [String] our description file
        def fetch(uri)
          store

          if cache_valid?(store[uri])
            templates = @store[uri][:templates]
          else
            templates = download_description_templates(uri)

            @store[uri] = { timestamp: Time.now, templates: templates }
          end

          templates
        end

        # Given a uri, remove the description from our store.
        #
        # @param [String] uri the uri of our description
        # @return [nil|Hash] returns nil if the description was not in the store,
        #   or a Hash representing the deleted description's entry
        def delete(uri)
          store

          @store.delete(uri)
        end

        # Returns a copy of our description store
        #
        # @return [Hash] returns our description store
        def store
          @store ||= {}
        end

        private

        # Given a description entry from our store, tell us if the cache is still valid
        #
        # @param [Hash] description_entry the entry we are checking
        # @return [Boolean] is the description cache valid?
        def cache_valid?(description_entry)
          return false if description_entry.nil?

          (Time.now <= (description_entry[:timestamp] + DESCRIPTION_CACHE_TIME))
        end

        # Given a description uri, download it and return the certificate data
        #
        # @param [String] uri the uri of our certificates
        # @return [String] certificate data
        def download_description_templates(uri)
          return if uri.nil?

          begin
            url = URI.parse(uri)
          rescue URI::InvalidURIError => e
            raise Parliament::OpenSearch::DescriptionError.new(uri), "Invalid description URI passed '#{uri}': #{e.message}"
          end

          request = Parliament::Request::BaseRequest.new(base_url: uri,
                                                         headers:  {
                                                             'Accept' => 'application/opensearchdescription+xml',
                                                             'Ocp-Apim-Subscription-Key' => ENV['OPENSEARCH_AUTH_TOKEN']
                                                         })
          xml_response = request.get

          begin
            xml_root = REXML::Document.new(xml_response.response.body).root
            templates = []
            xml_root.elements.each('Url') do |url|
              type = url.attributes['type']
              template = url.attributes['template']
              templates << { type: type, template: template }
            end

            raise Parliament::OpenSearch::DescriptionError.new(url), "The document found does not contain the required node. Attempted to get a 'Url' element with the attribute 'template'. Please check the description document at '#{url}' and try again." if templates.empty?
          rescue NoMethodError
            raise Parliament::OpenSearch::DescriptionError.new(url), "The document found does not appear to be XML. Please check the description document at '#{url}' and try again."
          end

          templates
        end
      end
    end
  end
end
