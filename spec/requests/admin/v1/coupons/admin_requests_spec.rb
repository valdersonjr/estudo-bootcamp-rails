require 'rails_helper'

RSpec.describe "Admin V1 Coupons as :admin", type: :request do
    let(:user) { create(:user, profile: :admin) }

    context "GET /coupons" do
        let(:url) { "/admin/v1/coupons" }
        let!(:coupons) { create_list(:coupon, 5) }

        it 'returns all Coupons' do
            get url, headers: auth_header(user)
            expect(body_json['coupons']).to contain_exactly *coupons.as_json(only: %i(id name code status discount_value max_use due_date))
        end

        it "returns sucess status" do
            get url, headers: auth_header(user)
            expect(response).to have_http_status(:ok)
        end
    end

    context "POST /coupons" do
        let(:url) { "/admin/v1/coupons" }

        context "with valid params" do
            let(:coupon_params) { { coupon: attributes_for(:coupon) }.to_json }

            it 'adds a new Coupon' do
                current_count = Coupon.count
                post url, headers: auth_header(user), params: coupon_params
                expect(Coupon.count).to eq(current_count + 1)
            end

            it 'returns last added Coupon' do
                post url, headers: auth_header(user), params: coupon_params
                expected_coupon = Coupon.last.as_json(only: %i(id name code status discount_value max_use due_date))
                expect(body_json['coupon']).to eq expected_coupon
            end

            it 'returns success status' do
                post url, headers: auth_header(user), params: coupon_params
                expect(response).to have_http_status(:ok)
            end
        end

        context "with invalid params" do
            let(:coupon_invalid_params) do
                { coupon: attributes_for(:coupon, name: nil) }.to_json
            end

            it 'does not add a new Coupon' do
                current_count = Coupon.count
                post url, headers: auth_header(user), params: coupon_invalid_params
                expect(Coupon.count).to eq(current_count)
            end

            it 'returns error messages' do
                post url, headers: auth_header(user), params: coupon_invalid_params
                expect(body_json['errors']['fields']).to have_key('name')
            end

            it 'returns unprocessable_entity status' do
                post url, headers: auth_header(user), params: coupon_invalid_params
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end

    context "PATCH /coupons/:id" do
        let(:coupon) { create(:coupon) }
        let(:url) { "/admin/v1/coupons/#{coupon.id}" }

        context "with valid params" do
            let(:new_name) { 'new name' }
            let(:coupon_params) { { coupon: { name: new_name } }.to_json }

            it 'updates Coupon' do
                patch url, headers: auth_header(user), params: coupon_params
                coupon.reload
                expect(coupon.name).to eq('new name')
            end

            it 'returns updated Coupon' do
                patch url, headers: auth_header(user), params: coupon_params
                coupon.reload
                expected_coupon = coupon.as_json(only: %i(id name code status discount_value max_use due_date))
                expect(body_json['coupon']).to eq expected_coupon
            end

            it 'returns success status' do
                patch url, headers: auth_header(user), params: coupon_params
                expect(response).to have_http_status(:ok)
            end
        end

        context "with invalid params" do
            let(:coupon_invalid_params) do
                { coupon: attributes_for(:coupon, name: nil) }.to_json
            end

            it 'does not update Coupon' do
                old_name = coupon.name
                patch url, headers: auth_header(user), params: coupon_invalid_params
                coupon.reload
                expect(coupon.name).to eq(old_name)
            end

            it 'returns error message' do
                patch url, headers: auth_header(user), params: coupon_invalid_params
                expect(body_json['errors']['fields']).to have_key('name')
            end

            it 'returns unprocessable_entity status' do
                patch url, headers: auth_header(user), params: coupon_invalid_params
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end

    context "DELETE /coupons/:id" do
        let!(:coupon) { create(:coupon) }
        let(:url) { "/admin/v1/coupons/#{coupon.id}" }

        context "with valid params" do
            it 'removes Coupon' do
                expect do  
                    delete url, headers: auth_header(user)
                end.to change(Coupon, :count).by(-1)
            end

            it 'returns success status' do
                delete url, headers: auth_header(user)
                expect(response).to have_http_status(:no_content)
            end

            it 'does not return any body content' do
                delete url, headers: auth_header(user)
                expect(body_json).to_not be_present
            end
        end
    end
end