module SidebarHelper
  attr_accessor :show_sidebar, :show_sidebar_sponsors

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
end
