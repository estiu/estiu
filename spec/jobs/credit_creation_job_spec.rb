describe CreditCreationJob do
  
  let(:user) { FG.create :user, :attendee_role }
  
  let!(:campaign) { FG.create :campaign, :with_referred_attendee, referred_attendee: user.attendee }
   
  let(:credit) {
    user.attendee.credits.first || fail
  }
  
  it 'works' do
    expect(CreditCreationMailer).to receive(:perform).at_least(1).times.and_call_original
    CreditCreationJob.perform_later credit.id
  end
  
end