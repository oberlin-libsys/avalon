require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/checkouts", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { FactoryBot.create(:user) }
  let(:media_object) { FactoryBot.create(:published_media_object, visibility: 'public') }
  let(:checkout) { FactoryBot.create(:checkout, user: user, media_object_id: media_object.id) }

  # This should return the minimal set of attributes required to create a valid
  # Checkout. As you add validations to Checkout, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { media_object_id: media_object.id }
  }

  let(:invalid_attributes) {
    { media_object_id: 'fake-id' }
  }

  before { sign_in(user) }

  describe "GET /index" do
    before { checkout }

    context "html request" do
      it "renders a successful response" do
        get checkouts_url
        expect(response).to be_successful
      end
      it "renders the index partial" do
        get checkouts_url
        expect(response).to render_template(:index)
      end
    end

    context "json request" do
      it "renders a successful JSON response" do
        get checkouts_url(format: :json)
        expect(response).to be_successful
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
      context "as a regular user" do
        before { FactoryBot.create(:checkout) }
        it "returns only the active user's checkouts" do
          get checkouts_url(format: :json)
          parsed_body = JSON.parse(response.body)
          expect(parsed_body['data'].count).to eq(1)
        end
      end
      context "as an admin user" do
        let(:user) { FactoryBot.create(:admin) }
        before { FactoryBot.create(:checkout) }
        it "returns all checkouts" do
          get checkouts_url(format: :json)
          parsed_body = JSON.parse(response.body)
          expect(parsed_body['data'].count).to eq(2)
        end
      end
      context "with display_returned param" do
        before :each do
          FactoryBot.create_list(:checkout, 2)
          FactoryBot.create(:checkout, user: user, return_time: DateTime.current - 1.day)
        end
        context "as a regular user" do
          it "renders a successful JSON response" do
            get checkouts_url(format: :json, params: { display_returned: true } )
            expect(response).to be_successful
            expect(response.content_type).to eq("application/json; charset=utf-8")
          end
          it "returns user's active and inactive checkouts" do
            get checkouts_url(format: :json, params: { display_returned: true } )
            parsed_body = JSON.parse(response.body)
            expect(parsed_body['data'].count).to eq(2)
          end
        end

        context "as an admin user" do
          let (:user) { FactoryBot.create(:admin) }
          it "renders a successful JSON response" do
            get checkouts_url(format: :json, params: { display_returned: true } )
            expect(response).to be_successful
            expect(response.content_type).to eq("application/json; charset=utf-8")
          end
          it "returns all checkouts" do
            get checkouts_url(format: :json, params: { display_returned: true } )
            parsed_body = JSON.parse(response.body)
            expect(parsed_body['data'].count).to eq(4)
          end
        end
      end
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get checkout_url(checkout, format: :json)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "json request" do
      context "with valid parameters" do
        it "creates a new Checkout" do
          expect {
            post checkouts_url, params: { checkout: valid_attributes, format: :json }
          }.to change(Checkout, :count).by(1)
        end

        it "returns created status" do
          post checkouts_url, params: { checkout: valid_attributes, format: :json }
          expect(response).to be_created
        end
      end

      context "with invalid parameters" do
        it "does not create a new Checkout" do
          expect {
            post checkouts_url, params: { checkout: invalid_attributes, format: :json }
          }.to change(Checkout, :count).by(0)
        end

        it "returns 404 because the media object cannot be found" do
          post checkouts_url, params: { checkout: invalid_attributes, format: :json }
          expect(response).to be_not_found
        end
      end
    end

    context "html request" do
      it "creates a new checkout" do
        expect {
          post checkouts_url, params: { checkout: valid_attributes }
        }.to change(Checkout, :count).by(1)
      end
      it "redirects to the media_object page" do
        post checkouts_url, params: { checkout: valid_attributes }
        expect(response).to redirect_to(media_object_url(checkout.media_object))
      end

      context "non-default lending period" do
        let(:media_object) { FactoryBot.create(:published_media_object, lending_period: 86400, visibility: 'public') }
        before { freeze_time }
        after { travel_back }
        it "creates a new checkout" do
          expect{
            post checkouts_url, params: { checkout: valid_attributes }
          }.to change(Checkout, :count).by(1)
        end
        it "sets the return time based on the given lending period" do
          post checkouts_url, params: { checkout: valid_attributes }
          expect(Checkout.find_by(media_object_id: media_object.id).return_time).to eq DateTime.current + 1.day
        end
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_return_time) { DateTime.now + 3.weeks }
      let(:new_attributes) {
        { return_time: new_return_time }
      }
      let(:invalid_new_attributes) {}

      it "updates the requested checkout" do
        patch checkout_url(checkout), params: { checkout: new_attributes, format: :json }
        checkout.reload
        checkout.return_time = new_return_time
      end

      it "redirects to the checkout" do
        patch checkout_url(checkout), params: { checkout: new_attributes, format: :json }
        checkout.reload
        expect(response).to be_ok
      end
    end

    context "with invalid parameters" do
      xit "returns a 422 Unprocessable entity" do
        patch checkout_url(checkout), params: { checkout: invalid_new_attributes, format: :json }
        expect(response).to be_unprocessable_entity
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested checkout" do
      # Make sure the checkout is created before the expect line below
      checkout
      expect {
        delete checkout_url(checkout)
      }.to change(Checkout, :count).by(-1)
    end

    it "redirects to the checkouts list" do
      delete checkout_url(checkout)
      expect(response).to redirect_to(checkouts_url)
      expect(flash[:notice]).not_to be_empty
    end

  end

  describe "PATCH /return" do
    it "updates the return time of requested checkout" do
      patch return_checkout_url(checkout)
      checkout.reload
      expect(checkout.return_time).to be <= DateTime.current
    end
    context "user is on the checkouts page" do
      it "redirects to the checkouts page" do
        patch return_checkout_url(checkout), headers: { "HTTP_REFERER" => checkouts_url }
        expect(response).to redirect_to(checkouts_url)
      end
    end
    context "user is on the item view page" do
      it "redirects to the item view page" do
        patch return_checkout_url(checkout), headers: { "HTTP_REFERER" => media_object_url(checkout.media_object)}
        expect(response).to redirect_to(media_object_url(checkout.media_object))
      end
    end
    context "the http referrer fails" do
      it "redirects to the checkouts page" do
        patch return_checkout_url(checkout)
        expect(response).to redirect_to(checkouts_url)
      end
    end
  end

  describe "PATCH /return_all" do
    before :each do
      FactoryBot.create_list(:checkout, 2)
      FactoryBot.create(:checkout, user: user)
    end

    context "as a regular user" do
      it "updates the user's active checkouts" do
        patch return_all_checkouts_url
        expect(Checkout.where(user_id: user.id).first.return_time).to be <= DateTime.current
      end
      it "does not update other checkouts" do
        patch return_all_checkouts_url
        expect(Checkout.where.not(user_id: user.id).first.return_time).to be > DateTime.current
        expect(Checkout.where.not(user_id: user.id).second.return_time).to be > DateTime.current
      end
      it "redirects to the checkouts list" do
        patch return_all_checkouts_url
        expect(response).to redirect_to(checkouts_url)
      end
    end
    context "as an admin user" do
      let(:user) { FactoryBot.create(:admin) }
      it "updates all active checkouts" do
        patch return_all_checkouts_url
        expect(Checkout.where("return_time <= ?", DateTime.current).count).to eq(3)
      end
      it "redirects to the checkouts list" do
        patch return_all_checkouts_url
        expect(response).to redirect_to(checkouts_url)
      end
    end
  end
end
