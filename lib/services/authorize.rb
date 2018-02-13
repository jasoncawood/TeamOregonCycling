require 'the_help/service'
module Services
  class Authorize < TheHelp::Service
    input :permission
    input :authorized, default: -> { true }

    authorization_policy allow_all: true

    main do
      Queries::RolesForUserAndPermission
        .count(user: context, permission: permission,
               result: method(:roles_counted))
    end

    callback(:roles_counted) { |count| process_role_count(count) }

    private

    def process_role_count(count)
      return authorized.call if count >= 1
      not_authorized.call
    end
  end
end
