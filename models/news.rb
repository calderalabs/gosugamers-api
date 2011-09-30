class News < RemoteModel
  attr_accessor :title, :description, :link
  
  self.site = "http://www.gosugamers.net"
  
  def self.find(args = {})
    if args[:game]
      game = args[:game].to_s
      find_from_site("#{site}/#{game}", args)
    else
      find_from_site("#{site}/general")
    end
  end
  
  def self.extract_from_contents(contents)

  end
end