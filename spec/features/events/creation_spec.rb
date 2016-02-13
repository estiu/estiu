describe 'Event creation', js: true do
  
  context "as an event_promoter" do
    
    sign_as :event_promoter, :feature
    
    let(:campaign) { FG.create :campaign, :fulfilled, campaign_draft: FG.create(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id) }
    
    before { visit new_event_campaign_path(id: campaign.id) }
    
    let(:ra1){ "dj/#{SecureRandom.hex}" }
    let(:ra2){ "dj/#{SecureRandom.hex}" }
    let(:ra3){ "dj/#{SecureRandom.hex}" }
    
    def fill_most
      find('#event_name').set SecureRandom.hex
      find('#event_venue_id').all("option")[1].select_option
      find('#event_starts_at_date').click
      next_month
      any_day
      options = find('#event_starts_at_hours').all("option")
      options[(1..(options.size - 1)).to_a.sample].select_option
      options = find('#event_duration_hours').all("option")
      options[(1..(options.size - 1)).to_a.sample].select_option
      find('#event_ra_artists_attributes_0_artist_path').set ra1
    end
    
    def the_action
      find('#new_event input[type=submit]').click
    end
    
    def click_add_another
      find('#add-another-ra-artist').click
    end
    
    def remove_last_ra_artist
      all('.remove-nested-attribute-item').last.click
    end
    
    def success n=2
      expect {
        the_action
      }.to change {
        Event.count
      }.by(1).and change{
        RaArtist.count
      }.by(n)
    end
    
    it "is possible to create an event" do
      
      fill_most
      click_add_another
      find('#event_ra_artists_attributes_1_artist_path').set ra2
      remove_last_ra_artist
      click_add_another
      find('#event_ra_artists_attributes_2_artist_path').set ra3
      
      success
      
      expect(RaArtist.order(id: :desc).limit(2).pluck(:artist_path)).to eq([ra3, ra1])
      
    end
    
    it 'is possible to remove additional ra_artist after failed creation' do
      fill_most
      click_add_another
      find('#event_ra_artists_attributes_1_artist_path').set 'INVALID'
      
      expect {
        the_action
      }.to_not change {
        [Event.count, RaArtist.count]
      }

      remove_last_ra_artist
      success 1
      expect(RaArtist.last.artist_path).to eq(ra1)
    end
    
  end
  
end
