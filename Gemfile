# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

gem 'bootsnap', '1.10.1', require: false
gem 'bootstrap-sass', '3.4.1'
gem 'hirb' # 出力結果を表として出力するgem
gem 'jbuilder', '2.11.5'
gem 'mysql2', '0.5.3'
gem 'net-http'
gem 'puma', '5.5.2'
gem 'rails', '~> 6.1.3', '>= 6.1.3.1'
gem 'sassc-rails', '2.1.2'
gem 'sass-rails', '6.0.0'
gem 'turbolinks', '5.2.1'
gem 'webpacker', '5.4.3'
gem 'chart-js-rails', '~> 0.1.4' # chart.js
gem 'pry-byebug'
gem 'pry-rails'
gem 'rails-i18n' # errorメッセージ日本語化

# Front
gem 'font-awesome-sass', '~> 5.15.1'
gem 'haml-rails'

# ユーザー認証
gem 'devise'
gem 'devise-i18n'

# Image uploader
gem 'carrierwave', '~> 2.0'
# S3へのアップロード
gem 'fog-aws'

# jsでrailsで定義した処理を使用
gem 'gon'

# 管理画面
gem 'cancancan'
gem 'rails_admin'

# enum日本語化
gem 'enum_help'

# 環境変数
gem 'dotenv-rails', groups: [:development, :test]

group :development, :test do
  gem 'byebug', '11.1.3'
  gem 'faker'
end

group :development do
  gem 'bullet' # N+1問題を検出するgem
  gem 'letter_opener_web' # メール送信確認用
  gem 'listen', '3.7.1'
  gem 'rack-mini-profiler', '2.3.3'
  gem 'rubocop', '~> 1.22', require: false
  gem 'spring', '3.1.1'
  gem 'web-console', '4.2.0'
end

group :test do
  gem 'capybara', '3.36.0'
  gem 'selenium-webdriver', '4.1.0'
  gem 'webdrivers', '5.0.0'
end

group :development, :test do
  gem "rspec-rails" # テストフレームワーク
  gem "factory_bot_rails" # テストデータ作成
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :production do
  gem 'pg', '1.2.3'
end
