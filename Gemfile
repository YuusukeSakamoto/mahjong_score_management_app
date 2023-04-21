source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

gem 'rails', '~> 6.1.3', '>= 6.1.3.1'
gem 'mysql2', '0.5.3'
gem 'puma', '5.5.2'
gem 'sass-rails', '6.0.0'
gem 'webpacker', '5.4.3'
gem 'turbolinks', '5.2.1'
gem 'jbuilder', '2.11.5'
gem 'bootsnap', '1.10.1', require: false
gem 'net-http'
gem "bootstrap-sass",  "3.4.1" # 
gem "sassc-rails",     "2.1.2"
gem 'hirb'         # 出力結果を表として出力するgem
gem 'hirb-unicode'  # マルチバイト文字の表示を補正するgem
gem 'rails-i18n' # errorメッセージ日本語化
gem 'chart-js-rails', '~> 0.1.4' #chart.js

group :development, :test do
  gem 'byebug', '11.1.3'
end

group :development do
  gem 'web-console', '4.2.0'
  gem 'rack-mini-profiler', '2.3.3'
  gem 'listen', '3.7.1'
  gem 'spring', '3.1.1'
end

group :test do
  gem 'capybara', '3.36.0'
  gem 'selenium-webdriver', '4.1.0'
  gem 'webdrivers', '5.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'devise'