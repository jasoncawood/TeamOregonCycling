class NewMembershipForm
  include ActiveModel::Model

  attr_accessor :membership_type_id, :accepts_code_of_conduct

  validates :membership_type_id, presence: true
  validates :accepts_code_of_conduct, acceptance: true
end
