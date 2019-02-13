class CheckMembershipStatus < ApplicationService
  input :user
  input :current, default: ->(_membership) {}
  input :expired, default: ->(_membership) {}
  input :no_history, default: -> {}

  require_permission :show, on: :user

  main do
    call_service(
      ListMembershipHistory,
      user: user,
      with_result: callback(:membership_history_retrieved)
    )
  end

  callback(:membership_history_retrieved) do |history|
    no_history! unless (self.membership = history.first)
    expired! if membership.expired?
    run_callback(current, membership)
  end

  private

  attr_accessor :membership

  def no_history!
    run_callback(no_history)
    stop!
  end

  def expired!
    run_callback(expired, membership)
    stop!
  end
end
