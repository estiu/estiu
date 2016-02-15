module AwsOps
  class Transient # transient infrastructure goes here - i.e. the resources that are created/deleted with each deploy.
    
    extend AwsOps
    
    def self.commit_digest
      current_commit[0..14]
    end
    
    def self.final_asg_name role_name, past_commit_digest=nil
      "#{role_name} - #{past_commit_digest || commit_digest}"
    end
    
    def self.asg_policy_name role_name, suffix
      "#{final_asg_name(role_name)} - #{suffix}"
    end
    
    def self.create_launch_configurations roles=ASG_ROLES
      roles.each do |role|
        opts = {
          launch_configuration_name: final_asg_name(role),
          image_id: ::AwsOps::Amis.latest_ami(role, PRODUCTION_SIZE),
          instance_type: AwsOps::PRODUCTION_SIZE,
          security_groups: ::AwsOps::Permanent.security_groups_per_worker[role],
          key_name: KEYPAIR_NAME,
          iam_instance_profile: Iam.instance_profile_arn,
          user_data: Base64.encode64(current_commit)
        }
        auto_scaling_client.create_launch_configuration(opts)
      end
    end
    
    def self.delete_launch_configurations only=nil
      names = only || auto_scaling_client.describe_launch_configurations.launch_configurations.map(&:launch_configuration_name)
      names.each do |name|
        auto_scaling_client.delete_launch_configuration launch_configuration_name: name
      end
      names.any?
    end
    
    def self.create_scaling_policies_for asg_name
      
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
    
    def self.initial_min_size
      1
    end
    
    def self.calculate_desired_capacity_for role
      value = (
        if old_asg(role)
          old_asg(role).instances.select{|i| i.lifecycle_state == 'InService' }.size
        else
          initial_min_size
        end)
      [value, initial_min_size].max
    end
    
    def self.create_asgs roles=ASG_ROLES
      
      roles.each do |asg_name|
        
        opts = {
          auto_scaling_group_name: final_asg_name(asg_name),
          launch_configuration_name: final_asg_name(asg_name),
          min_size: 0, # must be zero, else cannot peform B/G deployment by removing instances.
          max_size: 4,
          desired_capacity: calculate_desired_capacity_for(asg_name),
          new_instances_protected_from_scale_in: false,
          availability_zones: availability_zones,
          tags: [
            {
              key: 'commit',
              value: commit_digest
            },
            {
              key: 'environment',
              value: environment
            },
            {
              key: 'role',
              value: asg_name
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
        
        create_scaling_policies_for(asg_name)
        
      end
      
    end
    
    def self.new_asg role
      @@new_asg ||= {}
      @@new_asg[role] ||=
        (auto_scaling_client.describe_auto_scaling_groups.auto_scaling_groups.detect{|asg|
          asg.tags.detect{|tag|
            tag.key == 'role' && tag.value == role 
          } &&
          asg.tags.detect{|tag|
            tag.key == 'commit' && tag.value == commit_digest
          }
        })
    end
    
    def self.old_asg role
      @@old_asg ||= {}
      @@old_asg[role] ||=
        (auto_scaling_client.describe_auto_scaling_groups.auto_scaling_groups.reject {|asg|
          ASG_ROLES.map{|name| final_asg_name name }.include?(asg.auto_scaling_group_name)
        }.detect{|asg|
          asg.tags.detect{|tag|
            tag.key == 'role' && tag.value == role
          } &&
          asg.tags.detect{|tag|
            tag.key == 'commit' && tag.value != commit_digest
          }
        })
    end
    
    def self.delete_asgs only=nil
      names = only || auto_scaling_client.describe_auto_scaling_groups.auto_scaling_groups.select{|asg| asg.tags.detect{|tag|
        tag.key == 'environment' && tag.value == environment
      } }.map(&:auto_scaling_group_name)
      names.each do |name|
        auto_scaling_client.delete_auto_scaling_group auto_scaling_group_name: name, force_delete: true
      end
      names.any?
    end
    
    def self.asg_policy_for policy_name
      auto_scaling_client.describe_policies({
        policy_names: [policy_name]
      }).scaling_policies[0]
    end
    
    def self.setup_metrics_for_asgs roles=ASG_ROLES # metrics get auto-deleted when the associated ASG is deleted.
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
    
    def self.wait_until_new_asg_in_service role
      if LOAD_BALANCED_ASGS.include?(role)
        puts 'Waiting until ELB recognises the new ASG as "in service"...'
        elb_client.wait_until(
          :instance_in_service,
          {load_balancer_name: elb_name, instances: new_asg(role).instances.map(&:instance_id).map{|id| {instance_id: id} }})
      else
        puts 'Waiting until the EC2 instances have healthy state...'
        # XXX 
      end
      puts "Ready!"
    end
    
    def self.remove_old_asgs_instances!
      ASG_ROLES.each do |role|
        puts %|Processing old ASG for role #{role}...|
        wait_until_new_asg_in_service role
        puts 'Putting the old ASG instances in "stand by"...'
        auto_scaling_client.set_desired_capacity({
          auto_scaling_group_name: old_asg(role).auto_scaling_group_name,
          desired_capacity: 0,
          honor_cooldown: false
        })
      end
    end
    
    # this mechanism is needed for rollback only
    def self.restore_old_asgs_instances!
      
      puts "Putting old ASGs in service again..."
      
      ASG_ROLES.each do |role|
        
        auto_scaling_client.set_desired_capacity({
          auto_scaling_group_name: old_asg(role).auto_scaling_group_name,
          desired_capacity: calculate_desired_capacity_for(role),
          honor_cooldown: false
        })
        
        wait_until_new_asg_in_service role
        
      end
      
      puts "Old ASGs are in service again!"
      
    end
    
    def self.delete_old_asgs!
      puts "Deleting old ASGs.."
      ASG_ROLES.each do |role|
        old_commit = old_asg(role).tags.detect{|tag| tag.key == 'commit' }.value
        name = final_asg_name(role, old_commit)
        delete_asgs [name]
        delete_launch_configurations [name]
      end
      puts "Done!"
    end
    
  end
end