module Approvable
  
  def self.extended(base)
    base.class_eval do
      
      validates :submitted_at, presence: true, if: :approved_at
      validates :submitted_at, presence: true, if: :rejected_at
      validates :approved_at, inclusion: [nil], unless: :submitted_at
      validates :approved_at, inclusion: [nil], if: :rejected_at
      validates :rejected_at, inclusion: [nil], unless: :submitted_at
      validates :rejected_at, inclusion: [nil], if: :approved_at
      
      validate :approved_at_and_rejected_at_nil_when_submitting
      
      def self.approved
        where.not(approved_at: nil)
      end
      
      def self.rejected
        where.not(rejected_at: nil)
      end
      
      def must_be_reviewed?
        submitted_at && (!approved_at && !rejected_at)
      end
      
      def reviewed?
        approved_at || rejected_at
      end
      
      def approved_at_and_rejected_at_nil_when_submitting
        change = previous_changes[:submitted_at] # XXX is this correct in a `validate`? Its for after_commit I think
        if change && change[0].nil? && change[1].present?
          if approved_at
            errors[:approved_at] << 'Cannot be present when setting submitted_at'
          end
          if rejected_at
            errors[:rejected_at] << 'Cannot be present when setting submitted_at'
          end
        end
      end
      
      {approve!: :approved_at, reject!: :rejected_at}.each do |method, attr|
        define_method method do
          update_attributes!({attr => DateTime.now})
        end
      end
      
    end
  end
  
end