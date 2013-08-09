module Hudson
  # set default settings
  @@settings = {
    :url => 'http://localhost:8080',
    :user => nil,
    :password => nil,
    :version => nil,
  }

  def self.[](param)
    return @@settings[param]
  end

  def self.[]=(param, value)
    param = param.to_sym if param.kind_of?(String)
    if param.eql?(:host) or param.eql?(:url)
      value = "http://#{value}" if value !~ /https?:\/\//
      @@settings[:url] = value
    else
      @@settings[param] = value
    end
    HudsonObject::load_json_api
    BuildQueue::load_json_api
  end

  def self.settings=(settings)
    if settings.kind_of?(Hash)
      settings.each do |param, value|
        Hudson[param] = value
      end
    end
  end
end
