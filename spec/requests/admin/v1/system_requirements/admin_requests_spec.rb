require 'rails_helper'

RSpec.describe "Admin V1 System Requirements as :admin", type: :request do
    let(:user) { create(:user, profile: :admin) }

    context "GET /categories" do
        let(:url) { "/admin/v1/system_requirements" }
        let!(:system_requirements) { create_list(:system_requirement, 5) }

        it 'returns all System Requirements' do
            get url, headers: auth_header(user)
            expect(body_json['system_requirements']).to contain_exactly *system_requirements.as_json(only: %i(id name operational_system storage processor memory video_board))
        end

        it "returns sucess status" do
            get url, headers: auth_header(user)
            expect(response).to have_http_status(:ok)
        end
    end

    context "POST /system_requirements" do
        let(:url) { "/admin/v1/system_requirements" }

        context "with valid params" do
            let(:system_requirement_params) { { system_requirement: attributes_for(:system_requirement) }.to_json }

            it 'adds a new System Requirement' do
                current_count = SystemRequirement.count
                post url, headers: auth_header(user), params: system_requirement_params
                expect(SystemRequirement.count).to eq(current_count + 1)
            end

            it 'returns last added System Requirement' do
                post url, headers: auth_header(user), params: system_requirement_params
                expected_system_requirement = SystemRequirement.last.as_json(only: %i(id name operational_system storage processor memory video_board))
                expect(body_json['system_requirement']).to eq expected_system_requirement
            end

            it 'returns success status' do
                post url, headers: auth_header(user), params: system_requirement_params
                expect(response).to have_http_status(:ok)
            end
        end
    end

end