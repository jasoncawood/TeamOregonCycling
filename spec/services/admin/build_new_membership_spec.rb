require 'rails_helper'

RSpec.describe Admin::BuildNewMembership do
  let(:service_args) {{
    user: user
  }}

  let(:context_user) { instance_double('User') }

  let!(:user) { create(:user) }

  it_requires_permission :manage_users
end
