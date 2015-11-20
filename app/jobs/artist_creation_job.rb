class ArtistCreationJob < ApplicationJob
  
  def perform ra_path_id
    ra_path = ResidentAdvisorPath.find ra_path_id
  end
  
end