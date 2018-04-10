class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :membership_type

  monetize :amount_paid_cents

  validates :starts_on, :ends_on, :amount_paid, presence: true

  def status
    if Date.today.between?(starts_on, ends_on + 1.day)
      'current'
    elsif ends_on < Date.today
      'expired'
    else
      'pending'
    end
  end
end
