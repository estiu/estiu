module AwsOps
  class Iam
    
    ROLE_NAME = 'events'
    
    def self.s3_policy
      {
        "Version" => "2015-11-09",
        "Statement" => [
          {
            "Effect" => "Allow",
            "Action" => [
              "s3:Get*",
              "s3:List*"
            ],
            "Resource" => "arn:aws:s3:::events-env-vars/*"
          }
        ]
      }
    end
    
    def self.create_role
      iam_client.create_role({
        role_name: ROLE_NAME,
        # assume_role_policy_document: # no idea what a policy document is...
      })
    end
    
    # Has:
    # arn:aws:iam::320413926189:policy/s3-events-env-vars
    # arn:aws:iam::aws:policy/AWSDataPipelineFullAccess
    # arn:aws:iam::aws:policy/AmazonSQSFullAccess
    # arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
    def self.instance_profile_arn
      'arn:aws:iam::320413926189:instance-profile/events'
    end
    
  end
end