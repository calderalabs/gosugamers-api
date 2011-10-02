require 'nokogiri'

class News < RemoteModel
  attr_accessor :title, :link, :comment_count
  
  self.site = 'http://www.gosugamers.net'
  
  def self.find(args = {})
    game = args.delete(:game) || 'general'
    args[:start] = args.delete(:page) * 25 if args[:page]
    
    find_from_site("#{site}/#{game.to_s}/news/archive", args)
  end
  
  def self.extract_from_contents(contents)
    doc = Nokogiri::HTML(contents) do |config|
      config.noerror
    end
    
    doc.xpath("//tr[starts-with(@id, 'news')]/td[1]").map do |td|
      a = td.at_xpath('a')

      News.new(
        :title => a.content,
        :link => "#{site}/#{a['href']}",
        :comment_count => td.xpath('text()').to_s.squeeze(' ').strip[1..-1].to_i
      )
    end
  end
end