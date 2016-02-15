module AwsOps
  class Transient # transient infrastructure goes here - i.e. the resources that are created/deleted with each deploy.
    
    extend AwsOps
    
    def self.delete_launch_configurations
      names = auto_scaling_client.describe_launch_configurations.launch_configurations.map &:launch_configuration_name
      names.each do |name|
        auto_scaling_client.delete_launch_configuration launch_configuration_name: name
      end
      names.any?
    end
    
    # LCs don't support tags.
    # anyway, LCs don't support updating the AMI id, so the current setup is unfit for production.
    def self.create_launch_configurations roles=ASG_ROLES
      roles.each do |role|
        base_opts = {
          launch_configuration_name: role,
          image_id: ::AwsOps::Amis.latest_ami(role, PRODUCTION_SIZE),
          instance_type: AwsOps::PRODUCTION_SIZE,
          security_groups: ::AwsOps::Permanent.security_groups_per_worker[role],
          key_name: KEYPAIR_NAME,
          iam_instance_profile: Iam.instance_profile_arn
        }.freeze
        opts = base_opts.dup
        auto_scaling_client.create_launch_configuration(opts)
      end
    end
    
    def self.delete_asgs
      names = auto_scaling_client.describe_auto_scaling_groups.auto_scaling_groups.select{|asg| asg.tags.detect{|tag|
        tag.key == 'environment' && tag.value == environment
      } }.map(&:auto_scaling_group_name)
      names.each do |name|
        auto_scaling_client.delete_auto_scaling_group auto_scaling_group_name: name, force_delete: true
      end
      names.any?
    end
    
    def self.final_asg_name role_name
      "#{role_name} - #{current_commit[0..14]}"
    end
    
    def self.asg_policy_name role_name, suffix
      "#{final_asg_name(role_name)} - #{suffix}"
    end
    
    def self.create_asgs roles=ASG_ROLES
      
      roles.each do |asg_name|
        
        ami = ::AwsOps::Amis.latest_ami_object asg_name, AwsOps::PRODUCTION_SIZE
        commit = ami.tags.detect{|t|t.key == 'commit'}.try(&:value)
        
        opts = {
          auto_scaling_group_name: final_asg_name(asg_name),
          launch_configuration_name: asg_name,
          min_size: 1,
          max_size: 4,
          availability_zones: availability_zones,
          tags: [
            {
              key: 'commit',
              value: commit
            },
            {
              key: 'environment',
              value: environment
            }
          ]
        }
        if LOAD_BALANCED_ASGS.include?(asg_name)
          opts.merge!(
            {
              load_balancer_names: [elb_name],
              health_check_type: 'ELB',
              health_check_grace_period: AwsOps::ESTIMATED_INIT_TIME
            }
          ) 
        end
        auto_scaling_client.create_auto_scaling_group(opts)
        
        policy_common = {
          auto_scaling_group_name: final_asg_name(asg_name),
          policy_type: 'SimpleScaling',
          adjustment_type: 'ChangeInCapacity'
        }
        
        auto_scaling_client.put_scaling_policy(
          policy_common.merge(
            {
              policy_name: asg_policy_name(asg_name, AwsOps::SCALE_OUT_SUFFIX),
              scaling_adjustment: 1,
              cooldown: AwsOps::ESTIMATED_INIT_TIME
            }
          )
        )
        
        auto_scaling_client.put_scaling_policy(
          policy_common.merge(
            {
              policy_name: asg_policy_name(asg_name, AwsOps::SCALE_IN_SUFFIX),
              scaling_adjustment: -1,
              cooldown: AwsOps::CONNECTION_DRAINING_TIMEOUT
            }
          )
        )
        
      end
      
    end
    
    def self.asg_policy_for policy_name
      auto_scaling_client.describe_policies({
        policy_names: [policy_name]
      }).scaling_policies[0]
    end
    
    def self.setup_metrics_for_asgs roles=ASG_ROLES
      roles.each do |asg_name|
        common = {
          metric_name: 'CPUUtilization',
          namespace: 'AWS/EC2',
          statistic: 'Average',
          actions_enabled: true,
          period: 60,
          dimensions: [
            {
              name: 'AutoScalingGroupName',
              value: final_asg_name(asg_name),
            }
          ]          
        }
        cloudwatch_client.put_metric_alarm(
          common.merge(
            {
              alarm_name: asg_policy_name(asg_name, AwsOps::SCALE_OUT_SUFFIX),
              threshold: 70.0, # percentage
              comparison_operator: 'GreaterThanOrEqualToThreshold',
              alarm_actions: [asg_policy_for(asg_policy_name(asg_name, AwsOps::SCALE_OUT_SUFFIX)).policy_arn],
              evaluation_periods: 1
            }
          )
        )
        cloudwatch_client.put_metric_alarm(
          common.merge(
            {
              alarm_name: asg_policy_name(asg_name, AwsOps::SCALE_IN_SUFFIX),
              threshold: 50.0, # percentage
              comparison_operator: 'LessThanOrEqualToThreshold',
              alarm_actions: [asg_policy_for(asg_policy_name(asg_name, AwsOps::SCALE_IN_SUFFIX)).policy_arn],
              evaluation_periods: 35 # given that EC2 is billed by the hour, scaling in immediately doesn't give us any benefit - better to use the extra instances for as long as possible.
            }
          )
        )
      end
    end
    
  end
end