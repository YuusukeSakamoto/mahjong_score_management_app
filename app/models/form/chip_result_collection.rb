class Form::ChipResultCollection < Form::Base
  attr_accessor :chip_results, :session_players

  def initialize(play_type, attributes = {})
    super attributes
    self.chip_results = play_type.times.map { ChipResult.new() } unless self.chip_results.present?
  end

  def chip_results_attributes=(attributes)
    self.chip_results = attributes.map { |key, value| ChipResult.new(value) }
  end

  def save
    ChipResult.transaction do
      self.chip_results.map(&:save!)
    end      
      return true
    rescue => e
      return false
  end
  
  def find(mg_id)
    ChipResult.where(match_group_id: mg_id)
  end
end