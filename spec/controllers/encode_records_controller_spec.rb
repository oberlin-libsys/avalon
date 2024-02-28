# Copyright 2011-2024, The Trustees of Indiana University and Northwestern
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

# frozen_string_literal: true
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
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.
require 'rails_helper'

RSpec.describe EncodeRecordsController, type: :controller do
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ActiveEncodeEncodeRecordsController. Be sure to keep this updated too.
  let(:valid_session) { {} }
  let(:encode_record_test) { FactoryBot.create(:encode_record) }
  let(:user) { FactoryBot.create(:administrator) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end

    context 'when not administrator' do
      let(:user) { FactoryBot.create(:user) }

      it "redirects to restricted content page" do
        get :index, params: {}, session: valid_session
        expect(response).to render_template('errors/restricted_pid')
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: encode_record_test.to_param }, session: valid_session
      expect(response).to be_successful
    end

    context 'when not administrator' do
      let(:user) { FactoryBot.create(:user) }

      it "redirects to restricted content page" do
        get :index, params: {}, session: valid_session
        expect(response).to render_template('errors/restricted_pid')
      end
    end
  end

  describe "POST #paged_index" do
    before :each do
      FactoryBot.reload
      FactoryBot.create_list(:encode_record, 11)
    end

    context 'paging' do
      let(:common_params) { { order: { '0': { column: 1, dir: 'asc' } }, search: { value: '' } } }
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

    context 'filtering' do
      let(:common_params) { { start: 0, length: 20, order: { '0': { column: 3, dir: 'asc' } } } }
      it "returns results filtered by title" do
        post :paged_index, format: 'json', params: common_params.merge(search: { value: 'Title 98' }), session: valid_session
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['recordsFiltered']).to eq(2)
        expect(parsed_response['data'].count).to eq(2)
        expect(parsed_response['data'][0][3]).to eq('Title 988')
        expect(parsed_response['data'][1][3]).to eq('Title 989')
      end
    end

    context 'filtering' do
      let(:common_params) { { start: 0, length: 20, search: { value: '' } } }
      it "returns results sorted by title ascending" do
        post :paged_index, format: 'json', params: common_params.merge(order: { '0': { column: 3, dir: 'asc' } }), session: valid_session
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['data'][0][3]).to eq('Title 988')
        expect(parsed_response['data'][1][3]).to eq('Title 989')
      end
      it "returns results sorted by title descending" do
        post :paged_index, format: 'json', params: common_params.merge(order: { '0': { column: 3, dir: 'desc' } }), session: valid_session
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['data'][0][3]).to eq('Title 998')
        expect(parsed_response['data'][1][3]).to eq('Title 997')
      end
    end
  end

  describe "POST #progress" do
    let(:encode_1) { FactoryBot.create(:encode_record) }
    let(:encode_2) { FactoryBot.create(:encode_record) }
    let(:presenter_1) { EncodePresenter.new(encode_1) }
    let(:presenter_2) { EncodePresenter.new(encode_2) }

    it 'returns JSON with progress information' do
      post :progress, format: :json, params: { ids: [ encode_1.id, encode_2.id ] }, session: valid_session
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eq({ encode_1.id.to_s => { "progress" => presenter_1.progress, "status" => presenter_1.status },
                                                encode_2.id.to_s => { "progress" => presenter_2.progress, "status" => presenter_2.status } })
    end

    context 'when not administrator' do
      let(:user) { FactoryBot.create(:user) }

      it "redirects" do
        post :progress, format: :json, params: { ids: [ encode_1.id, encode_2.id ] }, session: valid_session
        expect(response).to be_unauthorized
      end
    end
  end
end
