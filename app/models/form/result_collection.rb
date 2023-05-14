class Form::ResultCollection < Form::Base
  FORM_COUNT = 4 #登録フォームの数を指定
  attr_accessor :results
  
  def initialize(attributes = {})
    super attributes
    self.results = FORM_COUNT.times.map { Result.new() } unless self.results.present?
  end
  
  def results_attributes=(attributes)
    self.results = attributes.map { |key, value| Result.new(value) }
  end
  
  def save
    Result.transaction do
      self.results.map do |result|
        result.save
      end
    end
      return true
    rescue => e
      return false
  end
end
