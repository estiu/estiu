describe 'Campaign displaying' do
  
  let(:campaign){ FG.create :campaign }
  
  before {
    visit campaign_path(campaign)
  }
  
  after {
    page_ok
  }
  
  context 'signed_out' do
    it 'works' do
    end
  end
  
  context 'as an event promoter' do
    sign_as :event_promoter, :feature
    it 'works' do
    end
  end
  
  context 'as an attendee' do
    sign_as :attendee, :feature
    it 'works' do
    end
  end
  
end