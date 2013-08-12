module Hudson
  class Build < HudsonObject
    attr_reader :number, :job

    def initialize(job, build_number = nil)
      @job = Job.new(job) if job.kind_of?(String)
      @job = job if job.kind_of?(Hudson::Job)
      @number = build_number.nil? ? @job.last_build : build_number

      raise "No build number##{@number} for the job #{@job}" unless
        @job.builds.include?(@number)

      load_json_api
    end

    def load_json_api
      api_base = "job/#{@job.name}/#{@number}"
      @api_build = "#{api_base}/api/json"
      @api_build_console = "#{api_base}/consoleText"
      @api_build_description = "#{api_base}/submitDescription"
    end

    def api(keys = nil, refresh = false)
      api_base(@api_build, keys, refresh)
    end

    def active?
      api('building', true)['building']
    end

    def description
      api('description', true)['description']
    end

    def description=(description)
      send_post_request(uri_for(@api_build_description), {
        :description => description,
        :json => "{\"description\": \"#{description}\"}",
        :Submit => 'Submit',
      })
    end

    def start_time
      Time.at(api('timestamp')['timestamp'] / 1000)
    end

    def end_time
      Time.at(start_time + api('duration')['duration'] / 1000)
    end

    def result
      api('result')['result']
    end

    def revisions
      api('changeSet[revisions]')['changeSet']['revisions']
    end

    def console
      get(uri_for(@api_build_console))
    end
  end
end
