# frozen_string_literal: true

class Match < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  belongs_to :league, optional: true # optional:trueで外部キーがnilでもDB登録できる
  has_many :results, dependent: :destroy # matchに紐づいたresultsも削除される
  accepts_nested_attributes_for :results # resultも同時に保存できるようになる

  validates :play_type, presence: true, inclusion: { in: [3, 4] }
  validates :match_on, presence: true
  validates :rule_id, presence: true
  validates :memo, length: { maximum: 50 }

  scope :desc, -> { order(match_on: :desc, created_at: :desc) } # 対局日付の降順
  scope :asc, -> { order(match_on: :asc, created_at: :asc) } # 対局日付の降順
  scope :match_ids, lambda { |match_ids, play_type|
                      where(id: match_ids).where(play_type: play_type)
                    } # play_typeに応じたmatch_idを配列で格納
  scope :league, ->(mg_ids) { where(match_group_id: mg_ids).asc } # リーグ対局のmatch_idをすべて取得する
  scope :count_in_match_group, ->(mg_id) { where(match_group_id: mg_id).count } # match_groupにおけるmatchの数

  attr_accessor :pre_path

  # ログインユーザーの該当対局のポイントを取得する
  def current_player_point(p_id)
    results.find_by(player_id: p_id)&.point
  end

  # match_groupの作成者の名前を返す
  def create_player_name
    match.player.name
  end

end
