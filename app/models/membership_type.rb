class MembershipType < ApplicationRecord
  include Discard::Model

  monetize :price_cents
  acts_as_list

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
