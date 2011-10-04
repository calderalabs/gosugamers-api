require 'nokogiri'

class News < RemoteModel
  self.site = 'http://www.gosugamers.net/:game/news/archive'
  self.element_xpath = "//tr[starts-with(@id, 'news')]/td[1]"

  field :created_at, DateTime
  field :title, String
  field :link, String
  field :comment_count, Integer

  replace_argument(:page, :start) { |p| p * 25 }
  default_argument(:game, 'general')
  
  def initialize_with_element(e)
    a = e.at_xpath('a')
    
    self.title = a.content
    self.link = "#{self.class.host}/#{a['href']}"
    self.comment_count = e.xpath('text()').to_s.squeeze(' ').strip[1..-1].to_i
  end
end