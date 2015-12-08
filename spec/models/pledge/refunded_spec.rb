describe Pledge do
  
  describe '#refunded?' do
    
    let(:pledge){ FG.create :pledge }
    
    [true, false].each do |charged|
      
      context "when there exists a credit refund (charged: #{charged})" do
        
        before {
          FG.create :credit, :refund, refunded_pledge: pledge, charged: charged
        }
        
        it "returns true" do
          
          expect(pledge.refunded?).to be true
          
        end
        
      end
    
    end
      
  end
  
end