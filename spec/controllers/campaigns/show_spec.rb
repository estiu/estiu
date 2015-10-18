describe CampaignsController do
  
  let(:campaign){ FG.create(:campaign) }
  
  before do
    expect(Campaign).to receive(:find).with(campaign.id.to_s).once.and_call_original
  end

  after do
    controller_ok
  end
  
  def the_action
    get :show, id: campaign.id
  end
  
  def stripe_expectation(negative=false)
    expect(response).send((negative ? :to_not : :to), render_template(partial: 'layouts/_stripe_checkout_form'))
  end
  
  describe '#show' do
    
    context 'signed out' do
      
      it "works, but it's not possible to pledge" do
        
        the_action
        stripe_expectation(:negative)
        
      end
      
    end
    
    context 'attendee' do
      
      sign_as :attendee
      
      it 'renders stripe_checkout_form' do
        the_action
        stripe_expectation
      end
      
      context 'when the attendee created a non-charged pledge' do
        
        before {
          Pledge.create!(attendee: attendee.attendee, campaign: campaign, amount_cents: campaign.recommended_pledge_amount_cents, stripe_charge_id: nil)
        }
        
        it 'renders stripe_checkout_form' do
          the_action
          stripe_expectation
        end
        
      end
      
      context 'when the attendee has already pledged' do
        
        before {
          Pledge.create!(attendee: attendee.attendee, campaign: campaign, amount_cents: campaign.recommended_pledge_amount_cents, stripe_charge_id: SecureRandom.hex)
        }

        it 'is not possible to pledge again' do
          
          the_action
          stripe_expectation(:negative)
          
        end
        
      end
      
    end
    
  end

end