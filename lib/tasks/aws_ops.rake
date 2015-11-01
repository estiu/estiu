namespace :aws_ops do
  
  task create: :environment do
    AwsOps::Infrastructure.create!
  end
  
  task delete: :environment do
    AwsOps::Infrastructure.delete!
  end
  
end
