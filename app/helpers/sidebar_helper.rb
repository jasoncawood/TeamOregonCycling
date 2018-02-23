module SidebarHelper
  attr_accessor :show_sidebar, :show_sidebar_sponsors

  attr_accessor :show_admin_sidebar, :show_admin_sidebar_manage_users

  alias show_sidebar? show_sidebar
  def show_sidebar!
    self.show_sidebar = true
    show_sidebar_sponsors!
  end
  def hide_sidebar!
    self.show_sidebar = false
  end

  alias show_sidebar_sponsors? show_sidebar_sponsors
  def show_sidebar_sponsors!
    self.show_sidebar_sponsors = true
  end
  def hide_sidebar_sponsors!
    self.show_sidebar_sponsors = false
  end

  alias show_admin_sidebar? show_admin_sidebar
  def show_admin_sidebar!
    self.show_admin_sidebar = true
  end
  def hide_admin_sidebar!
    self.show_admin_sidebar = false
  end

  alias show_admin_sidebar_manage_users? show_admin_sidebar_manage_users
  def show_admin_sidebar_manage_users!
    self.show_admin_sidebar_manage_users = true
  end
  def hide_admin_sidebar_manage_users!
    self.show_admin_sidebar_manage_users = false
  end
end
