class Membership < ApplicationRecord
  CURRENT = 'current'.freeze
  EXPIRED = 'expired'.freeze
  PENDING = 'pending'.freeze

  belongs_to :user
  belongs_to :membership_type

  monetize :amount_paid_cents

  validates :starts_on, :ends_on, :amount_paid, presence: true

  delegate :display_name, to: :user, prefix: true

  def status
    if Date.today.between?(starts_on, ends_on + 1.day)
      CURRENT
    elsif ends_on < Date.today
      EXPIRED
    else
      PENDING
    end
  end

  def expired?
    status == EXPIRED
  end

  def current?
    status == CURRENT
  end
end
