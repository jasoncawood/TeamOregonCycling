class MembershipType < ApplicationRecord
  include Discard::Model

  monetize :price_cents

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :weight, numericality: { only_integer: true, greater_than: 0 },
    uniqueness: true
end
