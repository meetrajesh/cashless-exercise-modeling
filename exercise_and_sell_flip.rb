# frozen_string_literal: true

# EXERCISE AND SELL METHODS (IMMEDIATELY SELL)
module ExerciseAndSellFlip
  extend Memoist

  def default_num_options_flipped_rightaway
    # for now, as a default, assume all NSOs will be flipped, and all ISOs and RSUs will be exercised & held, unless stated otherwise in the inputs
    nso? ? @num_options : 0
  end  

  def net_profit_on_flip
    pretax_flip_income - taxes_on_flip
  end

  def pretax_flip_income
    option_value * @num_options_sold_immediately_on_exercise
  end
  memoize :pretax_flip_income

  def taxes_on_flip
    tax_rate = (nso? || rsu?) ? @overall_ordinary_income_tax_rate : iso_flip_income_tax_rate
    pretax_flip_income * tax_rate
  end
end  
