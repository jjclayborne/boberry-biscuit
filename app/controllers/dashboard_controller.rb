class DashboardController < ApplicationController
  include StudioPages

  layout "studio"

  def show
    load_dashboard
  end
end
