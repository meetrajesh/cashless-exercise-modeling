# frozen_string_literal: true
require 'memoist'
require './stock_option_grant.rb'
require './helpers.rb'

class TaxReturn
  extend Memoist

  attr_reader :base_salaries

  def initialize
    @stock_actions = []
    @base_salaries = []
  end

  def add_base_salary(base_salary)
    raise "can't have more than 2 base salaries" if @base_salaries.size >= 2
    @base_salaries << base_salary
  end    

  def vest_rsu(num, current_fmv:)
    @stock_actions << StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.rsu, strike: 0, num_options: num)
  end

  def exercise_nso(num:, strike:, current_fmv:)
    @stock_actions << StockOptionGrant.new(
      type: StockOptionGrant::OPTION_TYPES.nso,
      strike: strike,
      num_options: num,
      exercise_time_fmv: current_fmv,
      num_flipped_rightaway: 0,
    )
  end

  def exercise_iso(num:, strike:, current_fmv:)
    @stock_actions << StockOptionGrant.new(
      type: StockOptionGrant::OPTION_TYPES.iso,
      strike: strike,
      num_options: num,
      exercise_time_fmv: current_fmv,
      num_flipped_rightaway: 0,
    )
  end

  def flip_iso(num:, strike:)
  end

  def flip_nso(num:, strike:)
  end

  def print_results
    regular_taxes = TaxCalculators.compute_all_taxes(total_regular_income)

    if @base_salaries.size == 2
      regular_taxes[:social_security] = base_salaries.sum { |bs| TaxCalculators.calculate_social_security_tax(bs, num_incomes: 1) }
    end

    extra_amt_tax = TaxCalculators.calculate_tentative_minimum_tax(total_regular_income + amt_extra_income) - TaxCalculators.calculate_federal_tax(total_regular_income)
    amt_tax_pct = extra_amt_tax / amt_extra_income.to_f * 100.0
    total_taxes_with_amt = regular_taxes.values.sum + extra_amt_tax
    total_tax_pct = total_taxes_with_amt / total_base_salary.to_f * 100.0
    take_home = total_base_salary - total_taxes_with_amt
    take_home_pct = take_home / total_base_salary.to_f * 100.0

    puts "INCOME"
    puts "=" * 20
    puts "Base Salary: #{cur(total_base_salary)} (#{base_salaries.map { |s| cur(s) }.join(' + ')})"
    puts "Stock Income: #{cur(total_regular_income - total_base_salary)}"
    puts "ISO Extra Income (for AMT): #{cur(amt_extra_income)}"
    puts
    puts

    puts "TAXES"
    puts "=" * 20
    regular_taxes.each do |type, amt|
      pct = amt / total_base_salary.to_f * 100.0
      puts "#{type.to_s.titleize} Tax: #{cur(amt)}" + " (#{pct.round(1)}%)"
    end
    puts
    puts "AMT Tax: #{cur(extra_amt_tax)} (#{amt_tax_pct.round(1)}%)"
    puts

    puts "SUMMARY"
    puts "=" * 20
    puts "Final Taxes: #{cur(total_taxes_with_amt)}" + " (#{total_tax_pct.round(1)}%)"
    puts "Take Home: #{cur(take_home)} (#{take_home_pct.round(1)}%)"

  end

  private

  def total_base_salary
    base_salaries.sum
  end
  memoize :total_base_salary

  def total_regular_income
    total_base_salary + @stock_actions.sum { |g| g.pretax_flip_income + g.nso_rsu_pretax_exercise_income }
  end
  memoize :total_regular_income

  def amt_extra_income
    @stock_actions.sum(&:income_for_amt_calculation)
  end
  memoize :amt_extra_income

end


# tax = TaxReturn.new
# tax.add_base_salary(200E3)
# tax.add_base_salary(150E3)
# tax.exercise_iso(num: 5_208, strike: 3.84, current_fmv: 16.10)
# tax.print_results
