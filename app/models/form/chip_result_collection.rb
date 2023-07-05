class Form::ChipResultCollection < Form::Base
  attr_accessor :chip_results, :session_players

  def initialize(attributes, action)
    if action == 'edit'
      unless self.chip_results.present?
        self.chip_results = attributes.map do |attribute|
          ChipResult.new(match_group_id: attribute["match_group_id"], 
                              player_id: attribute["player_id"], 
                              number: attribute["number"] ) 
        end
      end
    elsif action == 'create'
      super attributes
    end
  end

  def chip_results_attributes=(attributes)
    self.chip_results = attributes.map { |key, value| ChipResult.new(value) }
  end

  def save(mg)
    ChipResult.transaction do
      mg.chip_results.each(&:destroy!)
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