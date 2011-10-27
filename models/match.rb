class Match < RemoteModel
  synchronizable_on :starcraft, :starcraft2, :warcraft, :dota, :hon
  
  self.site = 'http://www.gosugamers.net/:game/gosubet'
  self.element_xpath = "//span[contains(text(), 'Upcoming matches')]/following::table[1]/tr[starts-with(@id, '/gosubet/')]"

  field :id, Integer
  field :eta, String
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
    self.eta = e.at_xpath('td[5]').text.strip
  end
  
  def to_notification
    Parse::Notification.new(
      :channels => "#{game}_matches",
      :alert => "#{player_one} vs #{player_two} in #{eta} (CET)",
      :badge => 1,
      :custom_data => { :url => link }
    )
  end
end