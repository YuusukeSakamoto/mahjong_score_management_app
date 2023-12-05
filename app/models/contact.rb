# frozen_string_literal: true

class Contact < ApplicationRecord
  validates :name, presence: true
  validates :content, presence: true
end
