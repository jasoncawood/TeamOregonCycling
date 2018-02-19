class Role < ApplicationRecord
  VALID_PERMISSIONS = %w[
    manage_users
  ]

  has_and_belongs_to_many :users

  validates :name, presence: true
  validates_intersection_of :permissions, in: VALID_PERMISSIONS
end
