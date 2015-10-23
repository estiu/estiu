describe CampaignFulfillmentJob do
  
  let(:campaign) { FG.create :campaign, :pledged }
  
  it 'works' do
    expect(CampaignFulfillment::AttendeeMailer).to receive(:perform).at_least(campaign.pledges.count).times.and_call_original
    expect(CampaignFulfillment::EventPromoterMailer).to receive(:perform).at_least(1).and_call_original
    CampaignFulfillmentJob.perform_later campaign.id
  end
  
end