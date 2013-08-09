module Hudson
  class System < HudsonObject
    class << self
      def api(keys = nil, refresh = false)
        api_base(@@api_hudson, keys, refresh)
      end

      def overallLoad(keys = nil, refresh = false)
        api_base(@@api_overallLoad, keys, refresh)
      end

      def jobs(*param)
        jobs = api('jobs[name]', true)
        jobs['jobs'].map { |j| j['name'] }
      end
    end
  end
end
