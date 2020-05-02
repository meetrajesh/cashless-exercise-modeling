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

  def vest_rsu(num:, current_fmv:)
    @stock_actions << StockOptionGrant.new(
      type: StockOptionGrant::OPTION_TYPES.rsu,
      strike: 0,
      num_options: num,
      exercise_time_fmv: current_fmv,
      num_flipped_rightaway: 0,
    )
  end
  alias_method :flip_rsu, :vest_rsu # same tax consequence

  def exercise_nso(num:, strike:, current_fmv:)
    @stock_actions << StockOptionGrant.new(
      type: StockOptionGrant::OPTION_TYPES.nso,
      strike: strike,
      num_options: num,
      exercise_time_fmv: current_fmv,
      num_flipped_rightaway: 0,
    )
  end
  alias_method :flip_nso, :exercise_nso # same tax consequence

  def exercise_iso(num:, strike:, current_fmv:)
    @stock_actions << StockOptionGrant.new(
      type: StockOptionGrant::OPTION_TYPES.iso,
      strike: strike,
      num_options: num,
      exercise_time_fmv: current_fmv,
      num_flipped_rightaway: 0,
    )
  end

  def flip_iso(num:, strike:, current_fmv:)
    @stock_actions << StockOptionGrant.new(
      type: StockOptionGrant::OPTION_TYPES.iso,
      strike: strike,
      num_options: num,
      exercise_time_fmv: current_fmv,
      num_flipped_rightaway: num,
    )
  end

  def print_results
    total_stock_income = total_regular_income - total_base_salary
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
    puts "Stock Income: #{cur(total_stock_income)}"
    puts "Total Regular Income: #{cur(total_regular_income)} (#{cur(total_base_salary)} + #{cur(total_stock_income)})"
    puts
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
    total_base_salary + stock_regular_income
  end
  memoize :total_regular_income

  def stock_regular_income
    @stock_actions.sum { |g| g.pretax_flip_income + g.nso_rsu_pretax_exercise_income }
  end
  memoize :stock_regular_income

  def amt_extra_income
    @stock_actions.sum(&:income_for_amt_calculation) - stock_regular_income
  end
  memoize :amt_extra_income

end


# example calls

tax = TaxReturn.new
tax.add_base_salary(200E3) # assume 19.5k 401(k) contribution
tax.add_base_salary(150E3) # assume 19.5k 401(k) contribution
tax.exercise_iso(num: 5_208, strike: 3.84, current_fmv: 16.10)
tax.flip_nso(num: 2_264, strike: 3.84, current_fmv: 16.10)
tax.vest_rsu(num: 2_264, current_fmv: 16.10)
tax.print_results
