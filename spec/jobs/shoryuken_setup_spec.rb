describe 'Estiu::Application.job_names' do
  
  it "Returns values which are identical to those used by each job" do
    
    a = Estiu::Application.job_names([Rails.env]).sort
    b = ApplicationJob::ESTIU_JOB_CLASSES.to_a.map{|subclass| ApplicationJob.format_queue_name subclass.name.to_s.underscore }.sort
    expect(a).to eq(b)
    
  end
  
end