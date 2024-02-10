# frozen_string_literal: true

class Matches::CalculatesController < ApplicationController
  def index
    points_ranks = []
    scores = []
    ies = []
    rule_id = params[:scores_rules_ies]['0'][0].to_i
    params[:scores_rules_ies]['1'].each do |d|
      scores << d.to_i
    end
    params[:scores_rules_ies]['2'].each do |d|
      ies << d.to_i
    end

    points_ranks << get_points_ranks(scores, rule_id, ies)

    respond_to do |format|
      format.html { redirect_to :root }
      format.json { render json: points_ranks }
    end
  end

  private

  # プレイヤーの得点・ルールに応じてptと順位を取得する
  def get_points_ranks(scores, rule_id, ies)
    rule = Rule.find(rule_id)
    sorted_scores = scores.sort.reverse # スコアで降順にする
    ranks = scores.map { |score| sorted_scores.index(score) + 1 } # 順位を配列で取得する
    # 同順位がある場合,下家の順位を下げる
    correct_tie_ranks(ranks, ies) if tie_exists?(ranks)
    # 点数計算方法方法に従って得点を修正する
    calculated_scores = calculate_score(scores, rule)
    # 素点の配列を作成
    sotens = calculated_scores.map { |score| get_soten(score, rule) }
    # # 小数点計算方法に従った素点を計算する
    # calculated_soten = calculate_decimal_point(soten, rule)
    uma_ary = [rule.uma_one, rule.uma_two, rule.uma_three, rule.uma_four]
    # ウマをptに反映させる
    points = sotens.map.with_index { |soten, i| soten + uma_ary[ranks[i] - 1] }
    # オカをptに反映させる
    oka = ((rule.kaeshi - rule.mochi) * rule.play_type) / 1000.to_f
    # 1位のptにウマを追加する
    points[ranks.index(1)] += oka
    # pt合計が0ではない場合、ズレてるptを一位ptに反映させる (小数点計算によって誤差が生まれてしまうもの)
    points[ranks.index(1)] -= points.sum unless points.sum.zero?
    points.map { |p| p.round(1) }
    [points, ranks]
  end

  # 素点を取得する(得点-返し)
  def get_soten(score, rule)
    (BigDecimal(format('%.1f', score / 10.to_f)) - BigDecimal(format('%.1f', rule.kaeshi / 1000.to_f))).to_f
  end

  # ポイントの小数点計算をする
  def calculate_score(scores, rule)
    sotens = scores.map { |score| score.to_f / 10 }
    case rule.score_decimal_point_calc
    when 1 # 小数点有効(小数点そのまま)
      sotens.map { |soten| soten * 10 }
    when 2 # 五捨六入
      sotens.map do |soten|
        if soten.to_s[-1].to_i <= 5 # 五捨
          soten.truncate * 10 # 切り捨て
        else # 六入
          soten > 0.0 ? soten.ceil * 10 : soten.floor * 10 # 正の数の場合：切り上げ、負の数の場合：切り下げ
        end
      end
    when 3 # 四捨五入
      sotens.map {|soten| soten.round * 10}
    when 4 # 切り捨て
      sotens.map do |soten|
        if soten >= 0
          soten.floor * 10 #小数点切り捨て
        else
          soten.truncate * 10 # truncate : 0に近い数字に切り捨てる
        end
      end
    when 5 # 切り上げ
      sotens.map do |soten|
        if soten >= 0
          soten.ceil * 10 #小数点切り上げ
        else
          soten.floor * 10 # より小さい値に切り上げる
        end
      end
    end
  end

  # 同順位があるか
  def tie_exists?(ranks)
    ranks.length != ranks.uniq.length
  end

  # 同順位の場合,下家の順位を下げる
  def correct_tie_ranks(ranks, ies)
    tie_ranks = ranks.select { |v| ranks.count(v) > 1 }.uniq # 同順位の値を配列で取得する
    tie_ranks.each do |tie_rank|
      tie_rank_idx = ranks.each_index.select { |i| ranks[i] == tie_rank } # 同順位のindexを配列で取得する
      ie_max = tie_rank_idx.map { |i| ies[i] }.max # 同順位のなかで最大値(=下家)を取得する
      ranks[ies.index(ie_max)] += 1 # 下家の順位を下げる
    end
  end
end
