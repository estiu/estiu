describe 'Campaign displaying' do
  
  let(:campaign){ FG.create :campaign }
  
  after {
    page_ok
  }
  
  context 'signed_out' do
    before { visit campaign_path(campaign) }
    it 'works' do
    end
  end
  
  context 'as an event promoter' do
    sign_as :event_promoter, :feature
    before { visit campaign_path(campaign) }
    it 'works' do
    end
  end
  
  context 'as an attendee' do
    sign_as :attendee, :feature
    before { visit campaign_path(campaign) }
    it 'works' do
    end
  end
  
end