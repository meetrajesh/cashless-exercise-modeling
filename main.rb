# frozen_string_literal: true

require './helpers.rb'
require './stock_option_grant.rb'
require './grants_private.rb'
require './compute_ordinary_income_tax_rate.rb'

money_incoming = GRANTS.sum(&:net_profit_on_flip)
money_outgoing = GRANTS.sum(&:total_cost_to_exercise_with_taxes)

puts
puts "Post-tax money incoming via exercise and sell (flip): #{cur(money_incoming)}"
puts "Post-tax cost to exercise and hold (excluding AMT): #{cur(money_outgoing)}"
puts "-" * 60
puts "Net cash incoming: #{cur(money_incoming - money_outgoing)}"
puts

# calculate AMT payable for ISOs
regular_income     = FINAL_YEAR_BASE_SALARY + GRANTS.sum { |g| g.pretax_flip_income + g.nso_rsu_pretax_exercise_income }
regular_income_tax = TaxCalculators.calculate_federal_tax(regular_income)
regular_income_tax_rate = regular_income_tax / regular_income.to_f

amt_income             = FINAL_YEAR_BASE_SALARY + GRANTS.sum { |g| g.pretax_flip_income + g.income_for_amt_calculation }
tmt_tax                = TaxCalculators.calculate_tentative_minimum_tax(amt_income)
$effective_amt_tax_rate = (tmt_tax / amt_income.to_f * 100.0).round(2)
$final_added_amt        = [0, (tmt_tax - regular_income_tax)].max

puts
puts "AMT Computation"
puts "-" * 16
print "Regular Income: " + cur(regular_income)
print "\t | "
puts "AMT Income: " + cur(amt_income)
print "Federal Tax: " + cur(regular_income_tax)
print "\t\t | "
puts "Tentative Tax: " + cur(tmt_tax)
print "(#{(regular_income_tax_rate*100).round(2)}%)"
print "\t\t\t | "
puts  "(#{$effective_amt_tax_rate}%)"

puts "-" * 60
puts "Difference (AMT owing): " + cur($final_added_amt)
puts "-" * 60

total_shares_sold    = GRANTS.sum(&:num_options_sold_immediately_on_exercise)
total_shares_held    = GRANTS.sum(&:num_options_exercised_and_held)
value_of_shares_sold = GRANTS.sum(&:pretax_flip_income)
value_of_shares_held = GRANTS.sum(&:exercise_time_value_of_shares)
percent_sold         = ((value_of_shares_sold / (value_of_shares_sold + value_of_shares_held).to_f) * 100.0).round

puts
puts "Final money incoming (after AMT):    -----> " + cur(money_incoming - money_outgoing - $final_added_amt) + " <----- "
puts
puts "Value of Shares Sold: " + cur(value_of_shares_sold) + " (#{num(total_shares_sold)} shares)"
puts "Value of Shares Held: " + cur(value_of_shares_held) + " (#{num(total_shares_held)} shares)"
puts "% sold:      -----> #{percent_sold}% <----- " 
puts


# final sale
pretax_value_of_shares_held = GRANTS.sum(&:pretax_value_at_final_sale)
long_term_cap_gains         = GRANTS.sum(&:capital_gains_tax_on_sale)
after_tax_value             = GRANTS.sum(&:after_tax_value) + $final_added_amt # add back in prepaid AMT

puts "Total Shares Held: " + num(total_shares_held)
puts "Value of Shares Held (Pre-Tax): " + cur(pretax_value_of_shares_held) + " (sale price of #{cur(StockOptionGrant::FINAL_SELL_PRICE)})"
puts "Capital Gains Tax: " + cur(long_term_cap_gains) + " (less prepaid AMT of #{cur($final_added_amt)})"
puts "Value of Shares Held (Post-Tax): " + cur(after_tax_value)



# ====================================================================================================================================================================================
# story time

require './story_time.rb'
