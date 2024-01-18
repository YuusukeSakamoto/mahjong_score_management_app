class ShareLinksController < ApplicationController
# 共有リンクの生成
  def new
    ShareLink.new
  end
end