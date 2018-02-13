module Queries
  class RolesForUserAndPermission
    include ActiveRecord::Sanitization::ClassMethods

    class << self
      def count(*args)
        new(*args).count
      end
    end

    def initialize(user:, permission:, result:)
      self.user = user
      self.permission = permission
      self.result = result
    end

    def count
      query = <<-SQL.squish
        SELECT COUNT(r.id) FROM roles r
          JOIN roles_users ru ON r.id = ru.role_id
          WHERE ru.user_id = :user_id
            AND r.permissions @> ARRAY[:permission]
      SQL
      query = sanitize_sql([query, user_id: user.id, permission: permission])
      result.call(connection.select_value(query))
    end

    private

    delegate :connection, to: ActiveRecord::Base

    attr_accessor :user, :permission, :result
  end
end
