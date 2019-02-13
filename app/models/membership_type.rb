class MembershipType < ApplicationRecord
  SKU_ITEM_TYPE = 'membership_type'

  include Purchasable

  include Discard::Model

  monetize :price_cents
  acts_as_list scope: 'discarded_at IS NULL'

  after_discard do
    MembershipType.kept.order(:position).each_with_index do |mtype, idx|
      mtype.update_attribute(:position, idx + 1)
    end
  end

  after_undiscard do
    MembershipType.kept.order(:position).each_with_index do |mtype, idx|
      mtype.update_attribute(:position, idx + 1)
    end
  end

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
