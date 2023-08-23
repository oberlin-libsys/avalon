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

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe PlaylistsController, type: :controller do
  include ActiveJob::TestHelper

  # This should return the minimal set of attributes required to create a valid
  # Playlist. As you add validations to Playlist, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { title: Faker::Lorem.word, visibility: Playlist::PUBLIC, user: user }
  end

  let(:invalid_attributes) do
    { visibility: 'unknown' }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PlaylistsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { login_as :user }

  describe 'security' do
    let(:playlist) { FactoryBot.create(:playlist, items: [playlist_item]) }
    let(:playlist_item) { FactoryBot.create(:playlist_item, clip: clip) }
    let(:clip) { FactoryBot.create(:avalon_clip, master_file: master_file) }
    let(:master_file) { FactoryBot.create(:master_file, media_object: media_object) }
    let(:media_object) { FactoryBot.create(:published_media_object, visibility: 'public') }

    context 'with unauthenticated user' do
      # New is isolated here due to issues caused by the controller instance not being regenerated
      it "should redirect to sign in" do
        expect(get :new).to render_template('errors/restricted_pid')
      end
      # Show is isolated because it does not require authorization before the action
      it "playlist view page should redirect to restricted content page" do
        expect(get :show, params: { id: playlist.id }).to render_template('errors/restricted_pid')
        expect(get :refresh_info, params: { id: playlist.id, position: 1 }, xhr: true).to render_template('errors/restricted_pid')
      end
      it "all routes should redirect to sign in" do
        expect(get :index).to render_template('errors/restricted_pid')
        expect(get :edit, params: { id: playlist.id }).to render_template('errors/restricted_pid')
        expect(post :create).to render_template('errors/restricted_pid')
        expect(put :update, params: { id: playlist.id }).to render_template('errors/restricted_pid')
        expect(put :update_multiple, params: { id: playlist.id }).to render_template('errors/restricted_pid')
        expect(delete :destroy, params: { id: playlist.id }).to render_template('errors/restricted_pid')
      end
      context 'with a public playlist' do
        let(:playlist) { FactoryBot.create(:playlist, visibility: Playlist::PUBLIC, items: [playlist_item]) }
        it "should return the playlist view page" do
          expect(get :show, params: { id: playlist.id }).not_to redirect_to(new_user_session_path)
          expect(get :show, params: { id: playlist.id }).to be_successful
          expect(get :refresh_info, params: { id: playlist.id, position: 1 }, xhr: true).to be_successful
        end
      end
      context 'with a private playlist' do
        it "should NOT return the playlist view page" do
          expect(get :show, params: { id: playlist.id }).to render_template('errors/restricted_pid')
          expect(get :refresh_info, params: { id: playlist.id, position: 1 }, xhr: true).to render_template('errors/restricted_pid')
        end
      end
      context 'with a private playlist and token' do
        let(:playlist) { FactoryBot.create(:playlist, :with_access_token, items: [playlist_item]) }
        it "should return the playlist view page" do
          expect(get :show, params: { id: playlist.id, token: playlist.access_token }).not_to redirect_to(root_path)
          expect(get :show, params: { id: playlist.id, token: playlist.access_token }).to be_successful
          expect(get :refresh_info, params: { id: playlist.id, position: 1, token: playlist.access_token }, xhr: true).to be_successful
        end
      end
    end
    context 'with end-user' do
      before do
        login_as :user
      end
      it "all routes should redirect to restricted content page" do
        expect(get :edit, params: { id: playlist.id }).to render_template('errors/restricted_pid')
        expect(put :update, params: { id: playlist.id }).to render_template('errors/restricted_pid')
        expect(put :update_multiple, params: { id: playlist.id }).to render_template('errors/restricted_pid')
        expect(delete :destroy, params: { id: playlist.id }).to render_template('errors/restricted_pid')
        expect(get :refresh_info, params: { id: playlist.id, position: 1 }, xhr: true).to render_template('errors/restricted_pid')
      end
      context 'with a public playlist' do
        let(:playlist) { FactoryBot.create(:playlist, visibility: Playlist::PUBLIC, items: [playlist_item]) }
        it "should return the playlist view page" do
          expect(get :show, params: { id: playlist.id }).not_to redirect_to(root_path)
          expect(get :show, params: { id: playlist.id }).to be_successful
          expect(get :refresh_info, params: { id: playlist.id, position: 1 }, xhr: true).to be_successful
        end
      end
      context 'with a private playlist' do
        it "should NOT return the pdfslaylist view page" do
          expect(get :show, params: { id: playlist.id }).to render_template('errors/restricted_pid')
          expect(get :refresh_info, params: { id: playlist.id, position: 1 }, xhr: true).to render_template('errors/restricted_pid')
        end
      end
      context 'with a private playlist and token' do
        let(:playlist) { FactoryBot.create(:playlist, :with_access_token, items: [playlist_item]) }
        it "should return the playlist view page" do
          expect(get :show, params: { id: playlist.id, token: playlist.access_token }).not_to redirect_to(root_path)
          expect(get :show, params: { id: playlist.id, token: playlist.access_token }).to be_successful
          expect(get :refresh_info, params: { id: playlist.id, position: 1, token: playlist.access_token }, xhr: true).to be_successful
        end
      end
    end
  end

  describe 'GET #index' do
    it 'assigns accessible playlists as @playlists' do
      # TODO: test non-accessible playlists not appearing
      playlist = Playlist.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:playlists)).to eq([playlist])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested playlist as @playlist' do
      playlist = Playlist.create! valid_attributes
      get :show, params: { id: playlist.to_param }, session: valid_session
      expect(assigns(:playlist)).to eq(playlist)
    end
    # TODO: write tests for public/private playists

    context 'read from solr' do
      render_views

      let!(:playlist) { FactoryBot.create(:playlist, items: [playlist_item], visibility: Playlist::PUBLIC) }
      let(:playlist_item) { FactoryBot.create(:playlist_item, clip: clip) }
      let(:clip) { FactoryBot.create(:avalon_clip, master_file: master_file) }
      let(:master_file) { FactoryBot.create(:master_file, media_object: media_object) }
      let(:media_object) { FactoryBot.create(:published_media_object, visibility: 'public') }

      it 'should not read from fedora' do
        perform_enqueued_jobs(only: MediaObjectIndexingJob)
        WebMock.reset_executed_requests!
        get :show, params: { id: playlist.id }
        expect(a_request(:any, /#{ActiveFedora.fedora.base_uri}/)).not_to have_been_made
      end
    end
  end

  describe 'GET #new' do
    before do
      login_as :user
    end
    it 'assigns a new playlist as @playlist' do
      get :new, params: {}, session: valid_session
      expect(assigns(:playlist)).to be_a_new(Playlist)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested playlist as @playlist' do
      playlist = Playlist.create! valid_attributes
      get :edit, params: { id: playlist.to_param }, session: valid_session
      expect(assigns(:playlist)).to eq(playlist)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Playlist' do
        expect do
          post :create, params: { playlist: valid_attributes }, session: valid_session
        end.to change(Playlist, :count).by(1)
      end

      it 'assigns a newly created playlist as @playlist' do
        post :create, params: { playlist: valid_attributes }, session: valid_session
        expect(assigns(:playlist)).to be_a(Playlist)
        expect(assigns(:playlist)).to be_persisted
      end

      it 'redirects to the created playlist' do
        post :create, params: { playlist: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Playlist.last)
      end

      it 'generates a token if visibility is private-with-token' do
        post :create, params: { playlist: valid_attributes.merge(visibility: Playlist::PRIVATE_WITH_TOKEN) }, session: valid_session
        expect(assigns(:playlist).access_token).not_to be_blank
      end
    end

    context 'with invalid params' do
      before do
        login_as :user
      end
      it 'assigns a newly created but unsaved playlist as @playlist' do
        post :create, params: { playlist: invalid_attributes }, session: valid_session
        expect(assigns(:playlist)).to be_a_new(Playlist)
      end

      it "re-renders the 'new' template" do
        post :create, params: { playlist: invalid_attributes }, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'POST #duplicate' do
    before do
      login_as :user
    end
    let(:new_attributes) do
      { title: Faker::Lorem.word, visibility: Playlist::PUBLIC, comment: Faker::Lorem.sentence, user: user }
    end
    let(:playlist) { FactoryBot.create(:playlist, new_attributes) }

    context 'blank playlist' do
      it 'duplicate a blank playlist' do
        post :duplicate, params: { format: 'json', old_playlist_id: playlist.id, playlist: { 'title' => playlist.title, 'comment' => playlist.comment, 'visibility' => playlist.visibility } }
        expect(response.body).not_to be_empty
        parsed_response = JSON.parse(response.body)

        new_playlist = Playlist.find(parsed_response['playlist']['id'])

        expect(new_playlist.id).not_to eq playlist.id
        expect(new_playlist.user_id).to eq playlist.user_id
        expect(new_playlist.visibility).to eq playlist.visibility
        expect(new_playlist.title).to eq playlist.title
        expect(new_playlist.comment).to eq playlist.comment
      end
    end

    context 'non-blank playlist' do

      let(:media_object) { FactoryBot.create(:media_object, visibility: 'public') }
      let!(:video_master_file) { FactoryBot.create(:master_file, media_object: media_object, duration: "200000") }
      let!(:clip) { AvalonClip.create(master_file: video_master_file, title: Faker::Lorem.word,
        comment: Faker::Lorem.sentence, start_time: 1000, end_time: 2000) }
      let!(:playlist_item) { PlaylistItem.create!(playlist: playlist, clip: clip) }
      let!(:bookmark) { AvalonMarker.create(playlist_item: playlist_item, master_file: video_master_file, start_time: "200000")}

        it 'duplicate playlist with items' do
          post :duplicate, params: { format: 'json', old_playlist_id: playlist.id, playlist: { 'title' => playlist.title, 'comment' => playlist.comment, 'visibility' => playlist.visibility } }
          expect(response.body).not_to be_empty
          parsed_response = JSON.parse(response.body)

          new_playlist = Playlist.find(parsed_response['playlist']['id'])
          expect(new_playlist.items.count).to eq 1
          expect(new_playlist.clips.first.start_time).to eq clip.start_time
          expect(new_playlist.clips.first.id).not_to eq clip.id
          expect(new_playlist.items.first.id).not_to eq playlist_item.id
          expect(new_playlist.items.first.marker.count).to eq 1

        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          { title: Faker::Lorem.word, visibility: Playlist::PUBLIC, comment: Faker::Lorem.sentence }
        end

        it 'updates the requested playlist' do
          playlist = Playlist.create! valid_attributes
          put :update, params: { id: playlist.to_param, playlist: new_attributes }, session: valid_session
          playlist.reload
          expect(playlist.title).to eq new_attributes[:title]
          expect(playlist.visibility).to eq new_attributes[:visibility]
          expect(playlist.comment).to eq new_attributes[:comment]
        end

        it 'assigns the requested playlist as @playlist' do
          playlist = Playlist.create! valid_attributes
          put :update, params: { id: playlist.to_param, playlist: new_attributes }, session: valid_session
          expect(assigns(:playlist)).to eq(playlist)
        end

        it 'redirects to edit playlist' do
          playlist = Playlist.create! valid_attributes
          put :update, params: { id: playlist.to_param, playlist: new_attributes }, session: valid_session
          expect(response).to redirect_to(edit_playlist_path(playlist))
        end

        it 'generates a token if visibility is private-with-token' do
          playlist = Playlist.create! valid_attributes
          put :update, params: { id: playlist.to_param, playlist: { visibility: Playlist::PRIVATE_WITH_TOKEN } }, session: valid_session
          playlist.reload
          expect(playlist.access_token).not_to be_blank
        end
      end

      context 'with invalid params' do
        it 'assigns the playlist as @playlist' do
          playlist = Playlist.create! valid_attributes
          put :update, params: { id: playlist.to_param, playlist: invalid_attributes }, session: valid_session
          expect(assigns(:playlist)).to eq(playlist)
        end

        it "re-renders the 'edit' template" do
          playlist = Playlist.create! valid_attributes
          put :update, params: { id: playlist.to_param, playlist: invalid_attributes }, session: valid_session
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'PUT #update_multiple' do
      before do
        login_as :user
      end

      let!(:playlist) { FactoryBot.create(:playlist, valid_attributes) }
      let!(:new_playlist) { FactoryBot.create(:playlist, valid_attributes) }

      let(:media_object) { FactoryBot.create(:media_object, visibility: 'public') }
      let!(:video_master_file) { FactoryBot.create(:master_file, media_object: media_object, duration: "200000") }
      let!(:clip) { AvalonClip.create(master_file: video_master_file, title: Faker::Lorem.word,
        comment: Faker::Lorem.sentence, start_time: 1000, end_time: 2000) }
      let!(:playlist_item) { PlaylistItem.create!(playlist: playlist, clip: clip) }
      let!(:bookmark) { AvalonMarker.create(playlist_item: playlist_item, master_file: video_master_file, start_time: "200000")}

      context 'delete' do

        it 'redirects to edit playlist' do
          put :update_multiple, params: { id: playlist.to_param, clip_ids: ["1"] }, session: valid_session
          expect(response).to redirect_to(edit_playlist_path(playlist))
        end

        it 'deletes a playlist item' do
          playlist.items << playlist_item
          expect(playlist.items.count).to eq(1)
          expect do
            # maybe request headers, run delete to see what gets pushed through.
            delete :update_multiple, params: { id: playlist.to_param, clip_ids:[ playlist_item.to_param ] }, session: valid_session
          end.to change(playlist.items, :count).by(-1)
        end
      end

      context 'copy_to' do
        it 'copys an item from one playlist to another' do
          playlist.items << playlist_item
          expect(playlist.items.count).to eq(1)
          expect do
            put :update_multiple, params: { id: playlist.id, clip_ids:[ playlist_item.to_param ], new_playlist_id: new_playlist.id, action_type: 'copy_to_playlist' }, session: valid_session
          end.to change(new_playlist.items, :count).by(+1)
          expect(playlist.items.count).to eq(1)
        end
      end

      context 'move_to' do
        it 'moves an item from one playlist to another' do
          playlist.items << playlist_item
          expect(playlist.items.count).to eq(1)
          expect do
            put :update_multiple, params: { id: playlist.id, clip_ids:[ playlist_item.to_param ], new_playlist_id: new_playlist.id, action_type: 'move_to_playlist' }, session: valid_session
          end.to change(new_playlist.items, :count).by(+1)
          expect(playlist.items.count).to eq(0)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested playlist' do
        playlist = Playlist.create! valid_attributes
        expect do
          delete :destroy, params: { id: playlist.to_param }, session: valid_session
        end.to change(Playlist, :count).by(-1)
      end

      it 'redirects to the playlists list' do
        playlist = Playlist.create! valid_attributes
        delete :destroy, params: { id: playlist.to_param }, session: valid_session
        expect(response).to redirect_to(playlists_url)
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested playlist as @playlist' do
        playlist = Playlist.create! valid_attributes
        get :edit, params: { id: playlist.to_param }, session: valid_session
        expect(assigns(:playlist)).to eq(playlist)
      end
    end

    context "Conditional Share partials should be rendered" do
      render_views
      let(:playlist) { FactoryBot.create(:playlist, visibility: Playlist::PUBLIC) }
      context "Normal login" do
        it "administrators: should include lti and share" do
          login_as(:administrator)
          get :show, params: { id: playlist.id }
          expect(response).to render_template(:_share_resource)
          expect(response).to render_template(:_lti_url)
        end
        it "Playlist owner: should include lti and share" do
          login_user playlist.user.user_key
          get :show, params: { id: playlist.id }
          expect(response).to render_template(:_share_resource)
          expect(response).to render_template(:_lti_url)
        end
        it "others: should include share and NOT lti" do
          login_as(:user)
          get :show, params: { id: playlist.id }
          expect(response).to render_template(:_share_resource)
          expect(response).to_not render_template(:_lti_url)
        end
      end
      context "LTI login" do
        it "administrators/managers/editors: should include lti and share" do
          login_lti 'administrator'
          lti_group = @controller.user_session[:virtual_groups].first
          get :show, params: { id: playlist.id }
          expect(response).to render_template(:_share_resource)
          expect(response).to render_template(:_lti_url)
        end
        it "others: should include only lti" do
          login_lti 'student'
          lti_group = @controller.user_session[:virtual_groups].first
          get :show, params: { id: playlist.id }
          expect(response).to_not render_template(:_share_resource)
          expect(response).to render_template(:_lti_url)
        end
      end
      context "No share tabs rendered" do
        before do
          @original_conditional_partials = controller.class.conditional_partials.deep_dup
          controller.class.conditional_partials[:share].each {|partial_name, conditions| conditions[:if] = false }
        end
        after do
          controller.class.conditional_partials = @original_conditional_partials
        end
        it "should not render Share button" do
          # allow(@controller).to receive(:evaluate_if_unless_configuration).and_return false
          # allow(@controller).to receive(:is_editor_or_not_lti).and_return false
          expect(response).to_not render_template(:_share)
        end
      end
      context "No LTI configuration" do
        around do |example|
          providers = Avalon::Authentication::Providers
          Avalon::Authentication::Providers = Avalon::Authentication::Providers.reject{|p| p[:provider] == :lti}
          example.run
          Avalon::Authentication::Providers = providers
        end
        it "should not include lti" do
          login_as(:administrator)
          get :show, params: { id: playlist.id }
          expect(response).to render_template(:_share_resource)
          expect(response).to_not render_template(:_lti_url)
        end
      end
    end

    describe "POST #paged_index" do
      before do
        login_as :user
      end
      before :each do
        FactoryBot.reload
        FactoryBot.create(:playlist, title: "aardvark", user: user)
        FactoryBot.create_list(:playlist, 9, title: 'bbbbb', user: user)
        FactoryBot.create(:playlist, title: "zzzebra", user: user)
      end

      context 'paging' do
        let(:common_params) { { order: { '0': { column: 0, dir: 'asc' } }, search: { value: '' }, columns: { '5': { search: { value: '' } } } } }
        it 'returns all results' do
          post :paged_index, format: 'json', params: common_params.merge(start: 0, length: 20), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['recordsTotal']).to eq(11)
          expect(parsed_response['data'].count).to eq(11)
        end
        it 'returns first page' do
          post :paged_index, format: 'json', params: common_params.merge(start: 0, length: 10), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'].count).to eq(10)
        end
        it 'returns second page' do
          post :paged_index, format: 'json', params: common_params.merge(start: 10, length: 10), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'].count).to eq(1)
        end
      end

      context 'searching' do
        let(:common_params) { { start: 0, length: 20, order: { '0': { column: 0, dir: 'asc' } } } }
        it "returns results filtered by title" do
          post :paged_index, format: 'json', params: common_params.merge(search: { value: "aardvark" }, columns: { '5': { search: { value: '' } } }), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['recordsFiltered']).to eq(1)
          expect(parsed_response['data'].count).to eq(1)
          expect(parsed_response['data'][0][0]).to eq("<a title=\"#{Playlist.all[0].comment}\" href=\"/playlists/1\">aardvark</a>")
        end
      end

      context 'sorting' do
        let(:common_params) { { start: 0, length: 20, search: { value: '' }, columns: { '5': { search: { value: '' } } } } }
        it "returns results sorted by title ascending" do
          post :paged_index, format: 'json', params: common_params.merge(order: { '0': { column: 0, dir: 'asc' } }), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'][0][0]).to eq("<a title=\"#{Playlist.all[0].comment}\" href=\"/playlists/1\">aardvark</a>")
          expect(parsed_response['data'][10][0]).to eq("<a title=\"#{Playlist.all[10].comment}\" href=\"/playlists/11\">zzzebra</a>")
        end
        it "returns results sorted by title descending" do
          post :paged_index, format: 'json', params: common_params.merge(order: { '0': { column: 0, dir: 'desc' } }), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'][0][0]).to eq("<a title=\"#{Playlist.all[10].comment}\" href=\"/playlists/11\">zzzebra</a>")
          expect(parsed_response['data'][10][0]).to eq("<a title=\"#{Playlist.all[0].comment}\" href=\"/playlists/1\">aardvark</a>")
        end
        it "returns results sorted by Created ascending" do
          post :paged_index, format: 'json', params: common_params.merge(order: { '0': { column: 3, dir: 'asc' } }), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'][0][0]).to eq("<a title=\"#{Playlist.all[0].comment}\" href=\"/playlists/1\">aardvark</a>")
          expect(parsed_response['data'][10][0]).to eq("<a title=\"#{Playlist.all[10].comment}\" href=\"/playlists/11\">zzzebra</a>")
        end
        it "returns results sorted by Created descending" do
          post :paged_index, format: 'json', params: common_params.merge(order: { '0': { column: 3, dir: 'desc' } }), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'][0][0]).to eq("<a title=\"#{Playlist.all[10].comment}\" href=\"/playlists/11\">zzzebra</a>")
          expect(parsed_response['data'][10][0]).to eq("<a title=\"#{Playlist.all[0].comment}\" href=\"/playlists/1\">aardvark</a>")
        end
        it "returns results sorted by Updated ascending" do
          post :paged_index, format: 'json', params: common_params.merge(order: { '0': { column: 4, dir: 'asc' } }), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'][0][0]).to eq("<a title=\"#{Playlist.all[0].comment}\" href=\"/playlists/1\">aardvark</a>")
          expect(parsed_response['data'][10][0]).to eq("<a title=\"#{Playlist.all[10].comment}\" href=\"/playlists/11\">zzzebra</a>")
        end
        it "returns results sorted by Updated descending" do
          post :paged_index, format: 'json', params: common_params.merge(order: { '0': { column: 4, dir: 'desc' } }), session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['data'][0][0]).to eq("<a title=\"#{Playlist.all[10].comment}\" href=\"/playlists/11\">zzzebra</a>")
          expect(parsed_response['data'][10][0]).to eq("<a title=\"#{Playlist.all[0].comment}\" href=\"/playlists/1\">aardvark</a>")
        end
      end
    end

    describe "GET #manifest" do
      let(:playlist) { FactoryBot.create(:playlist, items: [playlist_item], visibility: Playlist::PUBLIC) }
      let(:playlist_item) { FactoryBot.create(:playlist_item, clip: clip) }
      let(:clip) { FactoryBot.create(:avalon_clip, master_file: master_file) }
      let(:master_file) { FactoryBot.create(:master_file, :with_derivative, media_object: media_object) }
      let(:media_object) { FactoryBot.create(:published_media_object, visibility: 'public') }

      it "returns a IIIF manifest" do
        get :manifest, format: 'json', params: { id: playlist.id }, session: valid_session
        expect(response).to have_http_status(200)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['@context']).to include "http://iiif.io/api/presentation/3/context.json"
        expect(parsed_response['type']).to eq 'Manifest'
        expect(parsed_response['items']).not_to be_empty
      end

      context "when playlist owner" do
        before do
          login_user playlist.user.user_key
        end

        it "includes the marker annotation service definition" do
          get :manifest, format: 'json', params: { id: playlist.id }, session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["service"]).to be_present
        end
      end

      context "when not playlist owner" do
        it "does not include the marker annotation service definition" do
          get :manifest, format: 'json', params: { id: playlist.id }, session: valid_session
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["service"]).not_to be_present
        end
      end
    end
  end
