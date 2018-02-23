module Admin
  class BaseController < ApplicationController
    layout 'admin'

    attr_reader :show_admin_sidebar, :show_admin_sidebar_manage_users
    attr_reader :currently_managing

    private

    attr_writer :show_admin_sidebar, :show_admin_sidebar_manage_users
    attr_writer :currently_managing

    def self.currently_managing(managable)
      before_action do
        self.currently_managing = managable.to_sym
      end
    end

    def self.show_admin_sidebar_manage_users!
      before_action do
        self.show_admin_sidebar = true
        self.show_admin_sidebar_manage_users = true
      end
    end
  end
end
