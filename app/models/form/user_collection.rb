class Form::UserCollection < Form::Base
  FORM_COUNT = 4 #ここで、作成したい登録フォームの数を指定
  attr_accessor :users 

  def initialize(attributes = {})
    super attributes
    self.users = FORM_COUNT.times.map { User.new() } unless self.users.present?
  end

  def users_attributes=(attributes)
    self.users = attributes.map { |_, v| User.new(v) }
  end

  def save
    User.transaction do
      self.users.map do |user|
          user.save
      end
    end
      return true
    rescue => e
      return false
  end
end