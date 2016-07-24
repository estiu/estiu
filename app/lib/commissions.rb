class Commissions
  
  RATES_BY_THRESHOLDS = begin
    
    base = {
      
      200_00 => 0.2,
      300_00 => 0.15,
      400_00 => 0.1,
      500_00 => 0.095,
      650_00 => 0.0875,
      800_00 => 0.095,
      1000_00 => 0.1,
      2000_00 => 0.1,
      3000_00 => 0.1,
      4500_00 => 0.0875,
      6000_00 => 0.075,
      8000_00 => 0.0725,
      10000_00 => 0.07,
      12500_00 => 0.06,
      15000_00 => 0.055,
      20000_00 => 0.05
    }
    
    base.size.even? || fail
    
    # soften the curve. note: one cannot iterate again, else incorrect values arise.
    base.to_a.in_groups_of(2).each do |(left_threshold, left_rate), (right_threshold, right_rate)|
      base[((left_threshold + right_threshold) / 2.0).to_i] = (left_rate + right_rate) / 2.0
    end
    
    base.sort
    
  end
  
  def self.calculate_for campaign_draft
    base = campaign_draft.proposed_goal_cents
    return false if base.blank? || base.zero?
    rate = RATES_BY_THRESHOLDS.min_by{|k, v| (k - base).abs }.second
    (base.to_f * rate).to_i
  end
  
end