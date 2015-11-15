describe CampaignUnfulfillmentJob do
  
  let(:campaign) { FG.create :campaign, :almost_fulfilled }
  
  it 'works' do
    expect(CampaignUnfulfillment::AttendeeMailer).to receive(:perform).at_least(campaign.pledges.count).times.and_call_original
    expect(CampaignUnfulfillment::EventPromoterMailer).to receive(:perform).at_least(1).times.and_call_original
    CampaignUnfulfillmentJob.perform_later campaign.id
  end
  
end