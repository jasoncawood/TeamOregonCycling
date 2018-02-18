class User < ApplicationRecord
  include Discard::Model

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable, :lockable, :timeoutable

  has_and_belongs_to_many :roles
  has_many :memberships
  has_one :current_membership

  validates :email, :first_name, :last_name, presence: true

  def display_name
    [last_name, first_name].join(', ')
  end

  def membership_status
    current_membership&.status || 'none'
  end

  def active_for_authentication?
    super && !discarded?
  end

  def inactive_message
    I18n.t('account_inactive')
  end

  delegate :ends_on, to: :current_membership, prefix: :membership,
    allow_nil: true
end
