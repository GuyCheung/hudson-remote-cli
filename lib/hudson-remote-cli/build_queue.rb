module Hudson
  class BuildQueue < HudsonObject
    class << self
      def load_json_api
        @@api_build_queue = 'queue/api/json'
      end

      def api(refresh = false)
        super(@@api_build_queue, refresh)
      end
    end

    load_json_api
  end
end
