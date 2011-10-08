require 'nokogiri'

class Match < RemoteModel
  self.site = 'http://gosugamers.net/:game/gosubet'
  self.element_xpath = "//tr[starts-with(@id, '/gosubet/')]"

  field :date, DateTime
  field :game, String
  field :player_one, String
  field :player_two, String
  field :link, String
  field :comment_count, Integer

  replace_argument(:page, :start) { |p| ([p, 1].max - 1) * 25 }
  
  def initialize_with_element(e, from_site = nil)
    puts e.inner_html
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