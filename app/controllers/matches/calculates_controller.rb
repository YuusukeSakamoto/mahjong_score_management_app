class Matches::CalculatesController < ApplicationController
  
  def index
    points = []
    scores = []
    rule_id = params[:score_rules]["0"][0].to_i
    params[:score_rules]["1"].each do |d|
      scores << d.to_i
    end
    
    points = point_calculate(scores, rule_id)
    
    respond_to do |format| 
      format.html { redirect_to :root } 
      format.json { render json: points  }
    end
  end
  
  
  private
  
    # プレイヤーの得点・ルールに応じてptを計算する
    def point_calculate(scores, rule_id)
      rule = Rule.find(rule_id)
      sorted_scores = scores.sort.reverse # スコアで降順にする
      rank = scores.map{|n| sorted_scores.index(n) + 1} # 順位を配列で取得する
      
      # 得点 - 返し = 素点
      soten = scores.map{ |n| get_soten(n, rule) }
      # 小数点計算方法によって素点を計算する
      calculated_soten = calculate_decimal_point(soten, rule)
      uma_ary = [rule.uma_1, rule.uma_2, rule.uma_3, rule.uma_4]    
      # ウマをptに反映させる
      points = calculated_soten.map.with_index{ |n, i| n += uma_ary[rank[i] - 1] }
      # オカをptに反映させる
      oka = ((rule.kaeshi - rule.mochi ) * session[:players].count) / 1000.to_f
      points[rank.index(1)] += oka # 1位のptにウマを追加する
      return points
    end
    
    def get_soten(n, rule)
      (BigDecimal(sprintf("%.1f", n / 1000.to_f ) ) - BigDecimal(sprintf("%.1f", rule.kaeshi / 1000.to_f))).to_f
    end
    
    def calculate_decimal_point(soten, rule)
      case rule.score_decimal_point_calc
        when 1 #計算しない(小数点そのまま)
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

end
