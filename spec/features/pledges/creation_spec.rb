describe 'Pledge creation' do
  
  let(:campaign){ FG.create :campaign }

  context 'as an attendee' do
    
    sign_as :attendee, :feature
    
    context 'success', js: true do
    
      before {
        visit campaign_path(campaign)
      }
            
      let(:charge){
        double(id: SecureRandom.hex)
      }
      
      before {
        expect(Stripe::Charge).to receive(:create).once.with(any_args).and_return(charge)
        expect(charge).to receive(:id).exactly(2).times
      }
      
      def the_action
        
        find('#do-pledge').click
        
        within_frame 'stripe_checkout_app' do
          4.times { find('#card_number').send_keys "4242" } # In test mode, the 4242 4242 4242 4242 card is always valid for Stripe.
          find('#cc-exp').send_keys "12"
          find('#cc-exp').send_keys "20"
          find('#cc-csc').send_keys "999"
          find('#submitButton').click
        end
        
        sleep 7 # wait for Stripe processing + PledgesController#update processing
        
      end
      
      it 'is possible to create a charge through the Stripe Checkout form' do
        expect {
          the_action
        }.to change {
          campaign.pledges.count
        }.by(1)
      end
      
    end
    
    context 'if the attendee has already pledged' do
      
      after {
        page_ok
      }
          
      before {
        Pledge.create!(attendee: attendee.attendee, campaign: campaign, amount_cents: campaign.minimum_pledge_cents, stripe_charge_id: SecureRandom.hex)
        visit campaign_path(campaign)
      }

      it 'is not possible to pledge again' do
      
        expect(page).to have_content(t 'pledges.form.contributed', contributed: attendee.attendee.pledged_for(Campaign.last).format)
        
      end
      
    end
    
  end
  
end