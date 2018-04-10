class NewMembershipForm < SimpleDelegator
  attr_accessor :available_types
  private :available_types=

  def initialize(membership, available_types:)
    super(membership)
    self.available_types = available_types
  end
end
