class User < ApplicationRecord
  include Discard::Model

  has_secure_password

  has_and_belongs_to_many :roles
  has_many :memberships
  has_one :current_membership

  validates :email, :first_name, :last_name, presence: true
  validates :email, uniqueness: true

  def display_name
    [first_name, last_name].join(' ')
  end

  def membership_status
    current_membership&.status || 'none'
  end

  delegate :membership_type_name, to: :current_membership, prefix: false,
           allow_nil: true

  def inactive_message
    I18n.t('account_inactive')
  end

  def pending_reconfirmation?
    unconfirmed_email.present?
  end

  delegate :ends_on, to: :current_membership, prefix: :membership,
    allow_nil: true

  def anonymous?
    false
  end

  class Anonymous < User
    before_save do
      raise 'Cannot save an anonymous user.'
    end

    def anonymous?
      true
    end
  end
end
