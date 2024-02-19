# spec/models/share_link_spec.rb
require 'rails_helper'

RSpec.describe ShareLink, type: :model do
  let(:user) { create(:user) }
  let(:player) { create(:player) }
  let(:rule) { create(:rule) }
  let(:match_group) { create(:match_group, play_type: 4) }
  let!(:league) { create(:league, player: player, rule: rule) }

  describe 'ポリモーフィック関連付け' do
    context 'resourceがMatchGroupである場合' do
      it 'ShareLinkが有効である' do
        share_link = ShareLink.new(user: user, resource: match_group)
        expect(share_link).to be_valid
      end
    end

    context 'resourceがLeagueである場合' do
      it 'ShareLinkが有効である' do
        share_link = ShareLink.new(user: user, resource: league)
        expect(share_link).to be_valid
      end
    end

    context 'userが存在しない場合' do
      it 'ShareLinkが無効である' do
        share_link = ShareLink.new(user: nil, resource: match_group)
        expect(share_link).not_to be_valid
      end
    end

    context 'resourceが存在しない場合' do
      it 'ShareLinkが無効である' do
        share_link = ShareLink.new(user: user, resource: nil)
        expect(share_link).not_to be_valid
      end
    end
  end

  describe '.find_or_create' do
    context 'トークンが未発行である場合' do
      it '新しいShareLinkが作成される' do
        expect {
          ShareLink.find_or_create(user, 1, 'MatchGroup')
        }.to change(ShareLink, :count).by(0)
      end
    end

    context 'トークンが発行済みである場合' do
      let!(:share_link) { create(:share_link, user: user, resource: match_group) }
      it '既存のShareLinkが返される' do
        expect {
          ShareLink.find_or_create(user, 1, 'MatchGroup')
        }.not_to change(ShareLink, :count)
      end
    end
  end

  describe '.generate_reference_url' do
    context 'resource_typeがMatchGroupである場合' do
      let(:share_link) { create(:share_link, user: user, resource: match_group) }
      it 'MatchGroupのURLが生成される' do
        share_link.generate_reference_url('MatchGroup')
        expect(share_link.url).to include('match_group')
      end
    end
    context 'resource_typeがLeagueである場合' do
      let(:share_link) { create(:share_link, user: user, resource: league) }
      it 'LeagueのURLが生成される' do
        share_link.generate_reference_url('League')
        expect(share_link.url).to include('league')
      end
    end
  end
end