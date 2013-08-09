require 'net/http'
require 'net/https'
require 'rack/utils'
require 'zlib'
require 'json'
require 'hudson-remote-cli/version'
require 'hudson-remote-cli/config'

module Hudson
  autoload :System, 'hudson-remote-cli/system'
  autoload :BuildQueue, 'hudson-remote-cli/build_queue'
  autoload :Job, 'hudson-remote-cli/job'
  autoload :Build, 'hudson-remote-cli/build'

  class APIError < StandardError; end

  class HudsonObject
    def self.uri_for(path, query = {})
      uri = URI.parse(URI.encode(File.join(Hudson[:url], path)))
      uri.query = Rack::Utils.build_query(query)
      uri
    end

    def uri_for(path, query = {})
      self.class.uri_for(path, query)
    end

    def self.load_json_api
      @@_api_cache = Hash.new

      @@api_hudson = 'api/json'
      @@api_create_item = 'createItem'
      @@api_overallLoad = 'overallLoad/api/json'
    end

    load_json_api

    def self.hudson_request(uri, request)
       Net::HTTP.start(uri.host, uri.port) do |http|
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.request(request)
      end
    end

    def self.get(uri)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(Hudson[:user], Hudson[:password]) if
        Hudson[:user] and Hudson[:password]
      request['Content-Type'] = 'text/html'
      response = hudson_request(uri, request)

      if response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
        encoding = response.get_fields("Content-Encoding")
        if encoding and encoding.include?("gzip")
          return Zlib::GzipReader.new(StringIO.new(response.body)).read
        else
          return response.body
        end
      else
        $stderr.puts response.body
        raise APIError, "Error retrieving #{uri.request_uri}"
      end
    end

    def get(uri)
      self.class.get(uri)
    end

    def self.send_post_request(uri, data={})
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(Hudson[:user], Hudson[:password]) if
        Hudson[:user] and Hudson[:password]
      request.set_form_data(data)
      hudson_request(uri, request)
    end

    def send_post_request(uri, data={})
      self.class.send_post_request(uri, data)
    end

    def self.send_xml_post_request(uri, xml, data=nil)
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'text/xml'
      request.basic_auth(Hudson[:user], Hudson[:password]) if
        Hudson[:user] and Hudson[:password]
      request.set_form_data(data) if data
      request.body = xml
      hudson_request(uri,request)
    end

    def send_xml_post_request(uri, xml, data=nil)
      self.class.send_xml_post_request(uri, xml, data)
    end

    def self.api_base(api, keys = nil, refresh = false)
      cache_key = [api, keys.nil? ? '__ALL__' : keys].join '_'

      return @@_api_cache[cache_key] if
        @@_api_cache.has_key?(cache_key) and not refresh

      json = get(uri_for(api, keys.nil? ? {} : {:tree => keys}))
      @@_api_cache[cache_key] = JSON.load(json)
      @@_api_cache[cache_key]
    end

    def api_base(api, keys = nil, refresh = false)
      self.class.api_base(api, keys, refresh)
    end
  end

  def self.method_missing(method, *args, &block)
    Hudson::System.send(method, *args, block)
  end
end
