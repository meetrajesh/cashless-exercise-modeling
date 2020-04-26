# frozen_string_literal: true

grouped_grants     = GRANTS.group_by { |g| g.type.to_sym }
counts_by_type     = grouped_grants.transform_values { |g| {num: g.map(&:num_options).sum, value: g.map(&:pretax_option_value).sum} }
flip_by_type       = grouped_grants.transform_values { |g| g.map(&:num_options_sold_immediately_on_exercise).sum }
pretax_value_of_all_grants = GRANTS.sum(&:pretax_option_value)

overall_ordinary_income_tax_rate = (GRANTS.first.overall_ordinary_income_tax_rate * 100.0).round(2)
iso_flip_income_tax_rate         = (GRANTS.first.iso_flip_income_tax_rate * 100.0).round(2)

pretax_flip_income = GRANTS.sum(&:pretax_flip_income)
taxes_on_flip      = GRANTS.sum(&:taxes_on_flip)
money_incoming     = GRANTS.sum(&:net_profit_on_flip)

puts
puts "=" * 90
puts "STORY TIME"
puts
puts "You begin with #{num(counts_by_type[:nso][:num])} NSOs, #{num(counts_by_type[:iso][:num])} ISOs, and #{num(counts_by_type[:rsu][:num])} RSUs, each with a pretax worth of 
#{cur(counts_by_type[:nso][:value])}, #{cur(counts_by_type[:iso][:value])}, and #{cur(counts_by_type[:rsu][:value])} respectively at IPO. These add up to a total of
#{cur(pretax_value_of_all_grants)}. Upon IPO, you go ahead and sell (flip) #{num(flip_by_type[:nso])} NSOs, #{num(flip_by_type[:iso])} ISOs, and #{num(flip_by_type[:rsu])} RSUs.
Together, these generate proceeds of #{cur(pretax_flip_income)}. From this, you pay a tax rate of 
#{overall_ordinary_income_tax_rate}% on NSOs and RSUs and a tax rate of #{iso_flip_income_tax_rate}% on ISOs (#{StockOptionGrant::ISO_FLIP_MEDICARE_DISCOUNT*100.0}% Medicare discount).
This equates to a tax of #{cur(taxes_on_flip)}, leaving you with a net profit of #{cur(money_incoming)}."
puts

exercise_and_hold_by_type = grouped_grants.transform_values { |g| g.map(&:num_options_exercised_and_held).sum }
pretax_exercise_cost = GRANTS.sum(&:pretax_exercise_cost)
tax_on_exercise_and_hold = GRANTS.sum(&:tax_on_exercise_and_hold)
money_outgoing = GRANTS.sum(&:total_cost_to_exercise_with_taxes) + $final_added_amt

puts "From these generous proceeds, you then go ahead and exercise/hold the following: 
#{num(exercise_and_hold_by_type[:nso])} NSOs, #{num(exercise_and_hold_by_type[:iso])} ISOs, and #{num(exercise_and_hold_by_type[:rsu])} RSUs at an FMV of #{cur(StockOptionGrant::EXERCISE_TIME_FMV)}. The exercise costs you #{cur(pretax_exercise_cost)} 
(strike price) after which you also owe ordinary taxes of #{cur(tax_on_exercise_and_hold)} (#{overall_ordinary_income_tax_rate}%) and an AMT 
of #{cur($final_added_amt)} (#{$effective_amt_tax_rate}%) for a total of #{cur(money_outgoing)}."
puts

total_shares_held    = GRANTS.sum(&:num_options_exercised_and_held)
pretax_value_of_shares_held = GRANTS.sum(&:pretax_value_at_final_sale)
taxable_gain         = GRANTS.sum(&:taxable_gain)
basis_of_shares_held = pretax_value_of_shares_held - taxable_gain
long_term_cap_gains  = GRANTS.sum(&:capital_gains_tax_on_sale)
after_tax_value      = GRANTS.sum(&:after_tax_value) + $final_added_amt # add back in prepaid AMT

puts "In the end, you're left with #{cur(money_incoming)}-#{cur(money_outgoing)} = #{cur(money_incoming - money_outgoing)} net in the bank and #{num(total_shares_held)} exercised
shares. These shares will eventually have a total pretax value of #{cur(pretax_value_of_shares_held)} at a future
share price of #{cur(StockOptionGrant::FINAL_SELL_PRICE)}. These shares will then have a taxable gain of #{cur(taxable_gain)} after excluding 
the basis of #{cur(basis_of_shares_held)}. After paying a Federal long term capital gains tax of #{cur(long_term_cap_gains)} (at a rate
of #{FinalSaleLTCG::LTCG_TAX_RATE_FEDERAL*100.0}% which includes the NIIT), and accounting for an AMT prepaid tax credit of #{cur($final_added_amt)},
you are left with an after-tax value of #{cur(after_tax_value)} a number of years down the road.

By this time we assume you have moved out of pricey California, and so you don't owe 
taxes in California for the final sale of shares.
"


