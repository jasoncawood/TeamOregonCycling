module Admin
  class BaseController < ApplicationController
    layout 'admin'

    attr_accessor :show_admin_sidebar, :show_admin_sidebar_manage_users

    def self.show_admin_sidebar_manage_users!
      before_action do
        self.show_admin_sidebar = true
        self.show_admin_sidebar_manage_users = true
      end
    end
  end
end
