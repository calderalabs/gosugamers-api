class News < RemoteModel
  synchronizable_on :starcraft, :starcraft2, :warcraft, :dota, :dota2, :hon, :wow, :diablo, :poker
  
  self.site = 'http://www.gosugamers.net/:game/news/archive'
  self.element_xpath = "//tr[starts-with(@id, 'news')]"

  field :id, Integer
  field :created_at, DateTime
  field :game, String
  field :title, String
  field :link, String
  field :comment_count, Integer

  replace_argument(:page, :start) { |p| ([p, 1].max - 1) * 25 }
  default_argument(:game, 'general')
  
  sanitize_content do |content|
    content.
    gsub(/<\/span>(?:.*?)<\?/m, "<\/span><\/td><\/tr><\?").
    gsub(/<\? if\(\$_GET\['small_news'\] == '1'\)\{ \?>(?:.*?)<\?\} else \{\?>/m, "").
    gsub(/<\?.*\?>/, "")
  end
  
  def initialize_with_element(e)
    name_column = e.at_xpath('td[1]')
    date_column = e.at_xpath('td[2]')
    link = name_column.at_xpath('a')
    
    self.id = e['id'].gsub('news', '').to_i
    self.game = URI.parse(fetched_from).path.split('/')[1] if fetched_from
    self.title = link.content
    self.link = "#{self.class.host}/#{link['href']}"
    self.comment_count = name_column.text.strip[1..-1].to_i
    self.created_at = DateTime.parse(date_column.at_xpath('span')['title'])
  end
  
  def to_notification
    Parse::Notification.new(
      :channels => game,
      :alert => title,
      :badge => 1,
      :custom_data => { :url => link }
    )
  end
end