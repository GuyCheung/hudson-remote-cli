module Hudson
  class Job < HudsonObject
    attr_reader :name

    class << self
      def create(name, config_path)
        name.strip!

        config = File.open(config_path).read

        res = send_xml_post_request(
          uri_for(@@api_create_item, {:name => name}),
          config
        )
        raise(APIError, "Error creating job #{name}: #{res.body}") if
          res.class != Net::HTTPOK

        Job.new(name)
      end
    end

    def initialize(name)
      name.strip!
      raise "no job named #{name}!" unless Hudson.jobs.include?(name)
      @name = name
      load_json_api
    end

    def load_json_api
      @api_job = "job/#{@name}/api/json"
      @api_job_config = "job/#{@name}/config.xml"
      @api_job_description = "job/#{@name}/description"
      @api_job_build = "job/#{@name}/build"
      @api_job_withparam_build = "job/#{@name}/buildWithParameters"
      @api_job_delete = "job/#{@name}/doDelete"
      @api_job_disable = "job/#{@name}/disable"
      @api_job_enable = "job/#{@name}/enable"
    end

    def api(keys = nil, refresh = true)
      api_base(@api_job, keys, refresh)
    end

    def active?
      api('color')['color'].include?('anime')
    end

    def buildable?
      api('buildable')['buildable']
    end

    def last_success_build
      res = api('lastSuccessfulBuild[number]')['lastSuccessfulBuild']
      res.nil? ? 0 : res['number']
    end

    def last_build
      res = api('lastBuild[number]')['lastBuild']
      res.nil? ? 0 : res['number']
    end

    def builds
      res = api('builds[number]')['builds']
      res.nil? ? [] : res.map { |b| b['number'] }
    end

    def update(config)
      @config = File.open(config).read unless config.nil?
      res = send_xml_post_request(uri_for(@api_job_config), @config)
      @config = nil
      res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
    end

    def config
      return @config unless @config.nil?
      @config = get(uri_for(@api_job_config))
      @config
    end

    def description
      return @description unless @description.nil?
      @description = get(uri_for(@api_job_description))
      @description
    end

    def description=(description)
      @description = description
      send_post_request(uri_for(@api_job_description), {
        :description => @description
      })
    end

    def copy(name = nil)
      name = "copy_of_#{@name}" if name.nil?
      name.strip!
      res = send_post_request(uri_for(@@api_create_item), {
        :name => name,
        :mode => 'copy',
        :from => @name
      })
      raise(APIError, "Error copying job #{@name}: #{res.body}") if
        res.class != Net::HTTPFound
      Job.new(name)
    end

    def disable
      res = send_post_request(uri_for(@api_job_disable))
      res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
    end

    def enable
      res = send_post_request(uri_for(@api_job_enable))
      res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
    end

    def delete
      res = send_post_request(uri_for(@api_job_delete))
      res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
    end

    def build(param = {})
      response = nil
      if param.size.eql? 0
        response = send_post_request(uri_for(@api_job_build), {:delay => '0sec'})
      else
        param[:delay] = '0sec' unless param.has_key? :delay
        response = send_post_request(uri_for(@api_job_withparam_build), param)
      end
      response.is_a?(Net::HTTPSuccess) or response.is_a?(Net::HTTPRedirection)
    end

    def build!(param = {})
      build(param)
      wait_for_build
    end

    def wait_for_build(poll_freq = 10)
      loop do
        break if !active? and !BuildQueue.list.include?(@name)
        sleep poll_freq
      end
    end
  end
end
