require 'rails_helper'

RSpec.describe "Admin V1 Users as :admin", type: :request do
    let(:user_admin) { create(:user, profile: :admin) }
    
    context "GET /users" do
        let(:url) { "/admin/v1/users" }
        let!(:users) { create_list(:user, 5) }

        it "returns all users" do
            get url, headers: auth_header(user_admin)
            expected_users = users << user_admin #inclui o user_admin na lista de users
            expect(body_json['users']).to contain_exactly *expected_users.as_json(only: %i(id name email profile))
        end

        it "returns success status" do
            get url, headers: auth_header(user_admin)
            expect(response).to have_http_status(:ok)
        end
    end

    context "POST /users" do
        let(:url) { "/admin/v1/users" }

        context "with valid params" do
            let(:user_params) { { user: attributes_for(:user) }.to_json }

            it 'adds a new User' do
                user_admin.reload
                expect do
                    post url, headers: auth_header(user_admin), params: user_params
                end.to change(User, :count).by(1)
            end

            it 'returns last added User' do
                post url, headers: auth_header(user_admin), params: user_params
                expected_user = User.last.as_json(only: %i(id name email profile))
                expect(body_json['user']).to eq expected_user
            end

            it 'returns success status' do
                post url, headers: auth_header(user_admin), params: user_params
                expect(response).to have_http_status(:ok)
            end
        end
    end

    context "PATCH /users/:id" do
        let(:user) { create(:user) }
        let(:url) { "/admin/v1/users/#{user.id}" }

        context "with valid params" do
            let(:new_name) { 'new name' }
            let(:user_params) { { user: { name: new_name } }.to_json }

            it 'updates User' do
                patch url, headers: auth_header(user_admin), params: user_params
                user.reload
                expect(user.name).to eq('new name')
            end

            it 'returns updated User' do
                patch url, headers: auth_header(user_admin), params: user_params
                user.reload
                expected_user = user.as_json(only: %i(id name email profile))
                expect(body_json['user']).to eq expected_user
            end

            it 'returns success status' do
                patch url, headers: auth_header(user_admin), params: user_params
                expect(response).to have_http_status(:ok)
            end
        end

        context "with invalid params" do
            let(:user_invalid_params) do
                { user: attributes_for(:user, name: nil) }.to_json
            end

            it 'does not update User' do
                old_name = user.name
                patch url, headers: auth_header(user_admin), params: user_invalid_params
                user.reload
                expect(user.name).to eq(old_name)
            end

            it 'returns error messages' do
                patch url, headers: auth_header(user_admin), params: user_invalid_params
                expect(body_json['errors']['fields']).to have_key('name')
            end

            it 'returns unprocessable_entity status' do
                patch url, headers: auth_header(user_admin), params: user_invalid_params
                expect(response).to have_http_status(:unprocessable_entity)
            end
        end
    end  

    context "DELETE /users/:id" do
        let!(:user) { create(:user) }
        let(:url) { "/admin/v1/users/#{user.id}" }

        context "with valid params" do
            it 'removes User' do
                user_admin.reload
                expect do
                    delete url, headers: auth_header(user_admin)
                end.to change(User, :count).by(-1)
            end

            it 'returns success status' do
                delete url, headers: auth_header(user_admin)
                expect(response).to have_http_status(:no_content)
            end

            it 'does not return any body content' do
                delete url, headers: auth_header(user_admin)
                expect(body_json).to_not be_present
            end
        end
    end

end