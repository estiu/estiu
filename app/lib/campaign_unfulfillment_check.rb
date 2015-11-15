class CampaignUnfulfillmentCheck
  
  def self.run
    Campaign.where(unfulfilled_at: nil).where("ends_at <= ?", DateTime.now).each do |campaign|
      campaign.with_lock do
        if !campaign.unfulfilled_at
          campaign.update_attributes! unfulfilled_at: DateTime.now
        end
      end
    end
  end
  
end