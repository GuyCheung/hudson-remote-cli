module Hudson
  class BuildQueue < HudsonObject
    class << self
      def load_json_api
        @@api_build_queue = 'queue/api/json'
      end

      def api(keys = nil, refresh = false)
        api_base(@@api_build_queue, keys, refresh)
      end

      def list
        res = api_base(@@api_build_queue, 'items[task[name]]', true)['items']
        res.empty? ? [] : res.map { |i| i['task']['name'] }
      end
    end

    load_json_api
  end
end
