class PagesController < ApplicationController
  
  include HighVoltage::StaticPage
  
  skip_before_action :ensure_modern_browser
  skip_after_action :verify_authorized
  
end
