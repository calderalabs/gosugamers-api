class Replay < RemoteModel
  synchronizable_on :starcraft, :starcraft2, :warcraft, :dota, :hon
  
  self.site = 'http://www.gosugamers.net/:game/replays'
  self.element_xpath = "//tr[starts-with(@id, '/replays/')]"

  field :id, Integer
  field :date, Date
  field :game, String
  field :player_one, String
  field :player_two, String
  field :map, String
  field :link, String
  field :comment_count, Integer
  field :event, String
  field :download_count, Integer
  field :rating, Float
  
  replace_argument(:page, :start) { |p| ([p, 1].max - 1) * 25 }
  
  sanitize_content do |content|
    content.
    gsub(/<center>(.*?)((?:<td)|(?:<tr))/m, '<center>\1</center>\2').
    gsub(/<td(.*?)((?:<td)|(?:<tr))/m, '<td\1</td>\2')
  end
  
  def initialize_with_element(e)
    self.id = e['id'].gsub('/replays/', '').to_i
    self.game = URI.parse(fetched_from).path.split('/')[1] if fetched_from
    self.date = Date.parse(e.at_xpath('td[8]').text.strip)
    self.player_one = e.at_xpath('td[2]').text.strip
    self.player_two = e.at_xpath('td[3]').text.strip
    self.map = e.at_xpath('td[4]').text.strip
    self.link = "#{self.class.host}#{e['id']}"
    self.event = e.at_xpath('td[5]').text.strip
    self.comment_count = e.at_xpath('td[1]').text.strip[1..-1].to_i
    self.download_count = e.at_xpath('td[7]').text.to_i
    self.rating = e.at_xpath('td[6]').text.to_f
  end
  
  def to_notification
    Parse::Notification.new(
      :channels => [player_one, player_two],
      :alert => "#{player_one} vs #{player_two} (Event: #{event}) is out!",
      :badge => 1,
      :custom_data => { :url => link }
    )
  end
end