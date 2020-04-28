# frozen_string_literal: true

# FINAL SALE AFTER EXERCISE AND HOLD
module FinalSaleLTCG
  extend Memoist

  LTCG_TAX_RATE_FEDERAL = (17.91 + 3.28) / 100.0

  def cost_basis_after_exercise_and_hold
    iso? ? @strike : StockOptionGrant::EXERCISE_TIME_FMV
  end
  memoize :cost_basis_after_exercise_and_hold

  def pretax_value_at_final_sale
    StockOptionGrant::FINAL_SELL_PRICE * num_options_exercised_and_held
  end
  memoize :pretax_value_at_final_sale

  def taxable_gain
    return 0 if num_options_exercised_and_held == 0
    (StockOptionGrant::FINAL_SELL_PRICE - cost_basis_after_exercise_and_hold) * num_options_exercised_and_held
  end
  memoize :taxable_gain

  def capital_gains_tax_on_sale
    LTCG_TAX_RATE_FEDERAL * taxable_gain
  end
  memoize :capital_gains_tax_on_sale

  def after_tax_value
    pretax_value_at_final_sale - capital_gains_tax_on_sale
  end
end