# frozen_string_literal: true

class Form::ChipResultCollection < Form::Base
  attr_accessor :chip_results, :session_players

  def initialize(attributes, action)
    if action == 'edit'
      unless chip_results.present?
        self.chip_results = attributes.map do |attribute|
          ChipResult.new(match_group_id: attribute['match_group_id'],
                         player_id: attribute['player_id'],
                         number: attribute['number'])
        end
      end
    elsif action == 'update'
      super attributes
    end
  end

  def chip_results_attributes=(attributes)
    self.chip_results = attributes.map { |_key, value| ChipResult.new(value) }
  end

  def save(mg)
    ChipResult.transaction do
      mg.chip_results.each(&:destroy!)
      chip_results.map(&:save!)
    end
    true
  rescue StandardError => e
    Rails.logger.error e
  end

  def find(mg_id)
    ChipResult.where(match_group_id: mg_id)
  end
end
