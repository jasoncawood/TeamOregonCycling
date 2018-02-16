class Membership < ActiveRecord::Base
  belongs_to :user

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
