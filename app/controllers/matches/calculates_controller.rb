class Matches::CalculatesController < ApplicationController
  
  def index
    points_ranks = []
    scores = []
    ies = []
    rule_id = params[:scores_rules_ies]["0"][0].to_i
    params[:scores_rules_ies]["1"].each do |d|
      scores << d.to_i
    end
    params[:scores_rules_ies]["2"].each do |d|
      ies << d.to_i
    end
    
    
    points_ranks << get_points_ranks(scores, rule_id, ies)

    respond_to do |format| 
      format.html { redirect_to :root } 
      format.json { render json: points_ranks  }
    end
  end
  
  
  private
  
    # プレイヤーの得点・ルールに応じてptと順位を取得する
    def get_points_ranks(scores, rule_id, ies)
      rule = Rule.find(rule_id)
      sorted_scores = scores.sort.reverse # スコアで降順にする
      ranks = scores.map{|score| sorted_scores.index(score) + 1} # 順位を配列で取得する
      # 同順位がある場合,下家の順位を下げる
      correct_tie_ranks(ranks, ies) if tie_exists?(ranks)
      # 素点の配列を作成
      soten = scores.map{ |score| get_soten(score, rule) }
      # 小数点計算方法に従った素点を計算する
      calculated_soten = calculate_decimal_point(soten, rule)
      uma_ary = [rule.uma_1, rule.uma_2, rule.uma_3, rule.uma_4]    
      # ウマをptに反映させる
      points = calculated_soten.map.with_index{ |n, i| n += uma_ary[ranks[i] - 1] }
      # オカをptに反映させる
      oka = ((rule.kaeshi - rule.mochi ) * session_players_num) / 1000.to_f
      # 1位のptにウマを追加する
      points[ranks.index(1)] += oka 
      # pt合計が0ではない場合、ズレてるptを一位ptに反映させる (小数点計算によって誤差が生まれてしまうもの)
      points[ranks.index(1)] -= points.sum unless points.sum == 0
      points.map{ |p| p.round(1)}
      return points, ranks
    end
    
    # 素点を取得する(得点-返し)
    def get_soten(score, rule)
      (BigDecimal(sprintf("%.1f", score / 1000.to_f ) ) - BigDecimal(sprintf("%.1f", rule.kaeshi / 1000.to_f))).to_f
    end
    
    # ポイントの小数点計算をする
    def calculate_decimal_point(soten, rule)
      case rule.score_decimal_point_calc
        when 1 #小数点有効(小数点そのまま)
          soten
        when 2 #五捨六入
          soten.map do |n| 
            if n.to_s[-1].to_i <= 5 # 五捨
              n.truncate # 切り捨て
            else # 六入 
              n > 0.0 ? n.ceil : n.floor #正の数の場合：切り上げ、負の数の場合：切り下げ
            end
          end
        when 3 #四捨五入
          soten.map(&:round)
        when 4 #切り捨て
          soten.map(&:truncate) # truncate : 0に近い数字に切り捨てる
        when 5 #切り上げ
          soten.map(&:ceil)
      end
    end
    
    # 同順位があるか
    def tie_exists?(ranks)
      ranks.length != ranks.uniq.length
    end
    
    # 同順位の場合,下家の順位を下げる
    def correct_tie_ranks(ranks, ies)
      tie_ranks = ranks.select{|v| ranks.count(v) > 1}.uniq # 同順位の値を配列で取得する
      tie_ranks.each do |tie_rank|
        tie_rank_idx = ranks.each_index.select{|i| ranks[i] == tie_rank }  # 同順位のindexを配列で取得する
        ie_max = tie_rank_idx.map{ |i| ies[i] }.max # 同順位のなかで最大値(=下家)を取得する
        ranks[ies.index(ie_max)] += 1 # 下家の順位を下げる
      end
    end

end
