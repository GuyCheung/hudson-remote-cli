module Hudson
  class System < HudsonObject
    class << self
      def api(refresh = false)
        super(@@api_hudson, refresh)
      end
    end
  end
end
