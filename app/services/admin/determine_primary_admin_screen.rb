module Admin
  class DeterminePrimaryAdminScreen < BaseService
    input :url_generator
    input :with_result, default: ->(url) { url }

    authorization_policy allow_all: true

    main do
      try_manage_users
    end

    private

    def generate_url_for(**options)
      url = url_generator.call(**options)
      with_result.call(url)
      stop!
    end

    def try_manage_users
      call_service(Authorize, permission: :manage_users,
                   not_authorized: -> {},
                   authorized: -> {
                     generate_url_for(controller: 'admin/users', action: :index)
                   })
    end
  end
end
