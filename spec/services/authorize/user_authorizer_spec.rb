require 'rails_helper'

RSpec.describe Authorize::UserAuthorizer do
  let(:service_args) {{
    permission: permission,
    on: target,
    authorized: authorized,
    not_authorized: not_authorized
  }}

  let(:context_user) { create(:user, roles: [role]) }
  let(:role) { create(:role) }
  callback_double(:authorized, :not_authorized)

  let(:permission) { :whatever }
  let(:target) { double(is_a?: false) }

  shared_examples_for :it_is_not_authorized do
    it 'calls the not_authorized callback' do
      subject.call
      expect(not_authorized).to have_received(:call)
    end

    it 'does not call the authorized callback' do
      subject.call
      expect(authorized).not_to have_received(:call)
    end
  end

  shared_examples_for :it_is_authorized do
    it 'does not call the not_authorized callback' do
      subject.call
      expect(not_authorized).not_to have_received(:call)
    end

    it 'calls the authorized callback' do
      subject.call
      expect(authorized).to have_received(:call)
    end
  end

  def self.it_authorizes(*permissions)
    permissions.each do |p|
      context "a check for the #{p} permission" do
        let(:permission) { p }
        it_behaves_like :it_is_authorized
      end
    end
  end

  def self.it_denies(*permissions)
    permissions.each do |p|
      context "a check for the #{p} permission" do
        let(:permission) { p }
        it_behaves_like :it_is_not_authorized
      end
    end
  end

  it 'checks that the target is a User' do
    subject.call rescue nil
    expect(target).to have_received(:is_a?).with(User)
  end

  it 'raises an ArgumentError if the target is not a User' do
    expect { subject.call }.to raise_error ArgumentError
  end

  context 'when the user has the :manage_users permission' do
    before do
      role.update_attributes!(permissions: [:manage_users])
    end

    context 'when the target is the same as the context' do
      let(:target) { context_user }
      it_denies :delete
      it_authorizes :show, :update
    end

    context 'when the target is not the same as the context' do
      let(:target) { create(:user) }
      it_authorizes :show, :update, :delete
    end
  end

  context 'when the user does not have the :manage_users permission' do
    context 'when the target is the same as the context' do
      let(:target) { context_user }
      it_authorizes :show, :update, :delete
    end

    context 'when the target is not the same as the context' do
      let(:target) { create(:user) }
      it_denies :show, :update, :delete
    end
  end

  context 'when the target is the same user as the context' do
    let(:target) { context_user }

    context 'a check for the :delete permission' do
      let(:permission) { :delete }
      # Prevent users with the manage_users permission from deleting their own
      # account, so that we don't end up in a situation where there are no users
      # who have that permission.
      context 'when the user has the :manage_users permission' do
        before do
          role.update_attributes!(permissions: [:manage_users])
        end

        it_behaves_like :it_is_not_authorized
      end

      context 'when the user does not have the :manage_users permission' do
        it_behaves_like :it_is_authorized
      end
    end

    context 'a check for the :show permission' do
      let(:permission) { :show }

      it_behaves_like :it_is_authorized
    end
  end

  context 'when the target is not the same user as the context' do
    let(:target) { create(:user) }

    context 'a check for the :delete permission' do
      let(:permission) { :delete }

      context 'when the user has the :manage_users permission' do
        before do
          role.update_attributes!(permissions: [:manage_users])
        end

        it_behaves_like :it_is_authorized
      end

      context 'when the user does not have the :manage_users permission' do
        it_behaves_like :it_is_not_authorized
      end
    end
  end
end
