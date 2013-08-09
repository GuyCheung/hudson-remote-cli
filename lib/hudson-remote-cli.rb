require 'net/http'
require 'net/https'
require 'zlib'
require 'json'
require 'hudson-remote-cli/version'
require 'hudson-remote-cli/config'

module Hudson
  class HudsonObject
    def self.url_for(path)
      File.join Hudson[:url], path
    end

    def url_for(path)
      self.class.url_for(path)
    end

    def self.load_json_api
      @@api_hudson = 'api/json'
      @@api_create_item = 'createItem'
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

    def self.get(url)
      uri = URI.parse(URI.encode(url))
      host = uri.host
      port = uri.port
      path = uri.path
      request = Net::HTTP::Get.new(path)
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
        raise APIError, "Error retrieving #{path}"
      end
    end

    def get(url)
      self.class.get(url)
    end

    def self.send_post_request(url, data={})
      uri = URI.parse(URI.encode(url))
      host = uri.host
      port = uri.port
      path = uri.path
      request = Net::HTTP::Post.new(path)
      request.basic_auth(Hudson[:user], Hudson[:password]) if
        Hudson[:user] and Hudson[:password]
      request.set_form_data(data)
      hudson_request(uri, request)
    end

    def send_post_request(url, data={})
      self.class.send_post_request(url, data)
    end

    def self.send_xml_post_request(url, xml, data=nil)
      uri = URI.parse(URI.encode(url))
      host = uri.host
      port = uri.port
      path = uri.path
      path = path+"?"+uri.query if uri.query
      request = Net::HTTP::Post.new(path)
      request.basic_auth(Hudson[:user], Hudson[:password]) if
        Hudson[:user] and Hudson[:password]
      request.set_form_data(data) if data
      request.body = xml
      hudson_request(uri,request)
    end

    def send_xml_post_request(url, xml, data=nil)
      self.class.send_xml_post_request(url, xml, data)
    end

    def self.api(api, refresh = false)
      return @@api_cache[api] if @@api_cache.has_key?(api) and not refresh
      json = get(url_for(api))
      @@api_cache[api] = JSON.load(json)
      @@api_cache[api]
    end
  end

  def self.method_missing(method, *args, &block)
    Hudson::System.call(method, *args, block)
  end
end
