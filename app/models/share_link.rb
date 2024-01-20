class ShareLink < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true # 複数モデルに関連付け

  attr_reader :url

  # トークン発行済みであればインスタンス返却、
  # トークン未発行であれば発行してインスタンス返却
  def self.find_or_create(user, resource_id, resource_type)
    find_or_create_by(resource_type: resource_type, resource_id: resource_id) do |share_link|
      share_link.user_id = user.id
      share_link.token = SecureRandom.hex(10)
    end
  end

  # 参照URLを発行する
  def generate_reference_url
    @url = Rails.application.routes.url_helpers.
            match_group_url(id: self.resource_id,
                            tk: self.token,
                            host: Rails.application.routes.default_url_options[:host])
  end
end