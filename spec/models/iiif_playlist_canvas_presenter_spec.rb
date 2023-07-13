# Copyright 2011-2023, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

require 'rails_helper'

describe IiifPlaylistCanvasPresenter do
  let(:media_object) { FactoryBot.build(:media_object, visibility: 'private') }
  let(:derivative) { FactoryBot.build(:derivative) }
  let(:master_file) { FactoryBot.build(:master_file, media_object: media_object, derivatives: [derivative]) }
  let(:playlist_item) { FactoryBot.build(:playlist_item, clip: playlist_clip) }
  let(:playlist_clip) { FactoryBot.build(:avalon_clip, master_file: master_file) }
  let(:stream_info) { master_file.stream_details }
  let(:presenter) { described_class.new(playlist_item: playlist_item.clip, stream_info: stream_info) }

  context 'auth_service' do
    subject { presenter.display_content.first.auth_service }

    it 'provides a cookie auth service' do
      expect(subject[:@id]).to eq Rails.application.routes.url_helpers.new_user_session_url(login_popup: 1)
    end

    it 'provides a token service' do
      token_service = subject[:service].find { |s| s[:@type] == "AuthTokenService1"}
      expect(token_service[:@id]).to eq Rails.application.routes.url_helpers.iiif_auth_token_url(id: master_file.id)
    end

    it 'provides a logout service' do
      logout_service = subject[:service].find { |s| s[:@type] == "AuthLogoutService1"}
      expect(logout_service[:@id]).to eq Rails.application.routes.url_helpers.destroy_user_session_url
    end

    context 'when public media object' do
      let(:media_object) { FactoryBot.build(:media_object, visibility: 'public') }

      it "does not provide an auth service" do
        expect(presenter.display_content.first.auth_service).to be_nil
      end
    end
  end

  describe '#display_content' do
    subject { presenter.display_content.first }

    context 'when audio file' do
      let(:master_file) { FactoryBot.build(:master_file, :audio, media_object: media_object, derivatives: [derivative]) }

      it 'has format' do
        expect(subject.format).to eq "application/x-mpegURL"
      end
    end

    context 'when video file' do
      it 'has format' do
        expect(subject.format).to eq "application/x-mpegURL"
      end
    end
  end

  describe '#range' do
    subject { presenter.range }

    it 'generates a the clip range' do
    	expect(subject.label.to_s).to eq "{\"none\"=>[\"#{master_file.embed_title}\"]}"
    	expect(subject.items.size).to eq 1
    	expect(subject.items.first).to be_a IiifPlaylistCanvasPresenter
      expect(subject.items.first.media_fragment).to eq "t=#{playlist_clip.start_time/1000},#{playlist_clip.end_time/1000}"
    end
  end

  describe '#part_of' do
    subject { presenter.part_of }

    it 'references the parent media object manifest' do
      expect(subject.first['type']).to eq 'manifest'
      expect(subject.any? { |po| po["@id"] =~ /media_objects\/#{media_object.id}\/manifest/ }).to eq true
    end
  end
end
