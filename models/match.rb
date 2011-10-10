class Match < RemoteModel
  self.site = 'http://www.gosugamers.net/:game/gosubet'
  self.element_xpath = "//span[contains(text(), 'Upcoming matches')]/following::table[1]/tr[starts-with(@id, '/gosubet/')]"

  field :id, Integer
  field :date, DateTime
  field :game, String
  field :player_one, String
  field :player_two, String
  field :link, String
  field :comment_count, Integer
  field :bet_count, Integer
  
  replace_argument(:page, :start) { |p| ([p, 1].max - 1) * 25 }
  
  def initialize_with_element(e)
    self.id = e['id'].gsub('/gosubet/', '').to_i
    self.link = "#{self.class.host}#{e['id']}"
    self.comment_count = e.at_xpath('td[1]/center').text.strip[1..-1].to_i
    self.player_one = e.at_xpath('td[2]/a').text.strip
    self.player_two = e.at_xpath('td[3]/a').text.strip
    self.bet_count = e.at_xpath('td[4]').text.strip.to_i
    
    self.game = URI.parse(fetched_from).path.split('/')[1] if fetched_from
    
    if fetched_at
      eta = e.at_xpath('td[5]').text.strip
      hours = /([0-9]+)h/m.match(eta).to_a[1].to_i
      mins = /([0-9]+)m(in)?/m.match(eta).to_a[1].to_i
      
      self.date = fetched_at.new_offset(1/24) + Date::Delta.hours(hours) + Date::Delta.minutes(mins)
    end
  end
  
  def to_notification
    Parse::Notification.new(
      :channels => [player_one, player_two],
      :alert => "#{player_one} vs #{player_two} at #{date}",
      :badge => 1,
      :custom_data => { :url => link }
    )
  end
end