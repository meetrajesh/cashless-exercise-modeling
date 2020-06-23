# frozen_string_literal: true

# ASSUME married filing jointly (MFJ)
# ASSUME 2020 tax rates, thresholds, and amounts
module TaxCalculators

  def self.compute_all_taxes(income, num_incomes: 2)
    check_num_incomes!(num_incomes)

    {
      federal: calculate_federal_tax(income, num_incomes: num_incomes),
      state: calculate_california_tax(income, num_incomes: num_incomes),
      social_security: calculate_social_security_tax(income, num_incomes: num_incomes),
      medicare: calculate_medicare_tax(income), # medicare does not depend on num_incomes
    }
  end

  def self.compute_tax_rate_on_stock_income_only(base_salary, stock_income)
    base_salary = integerize(base_salary)
    stock_income = integerize(stock_income)

    diff = compute_overall_taxes(base_salary + stock_income) - compute_overall_taxes(base_salary)
    diff / stock_income.to_f
  end

  def self.compute_overall_taxes(income, num_incomes: 2)
    check_num_incomes!(num_incomes)

    return 0.0 if income == 0
    compute_all_taxes(income, num_incomes: num_incomes).values.sum
  end

  def self.compute_overall_tax_rate(income, num_incomes: 2)
    check_num_incomes!(num_incomes)

    income = integerize(income)
    return 0.0 if income == 0

    total_tax = compute_overall_taxes(income, num_incomes: num_incomes)
    total_tax / income.to_f
  end

  RETIREMENT_401K_LIMIT = 19_500 # 401k tax deductions for year 2020

  # federal tax constants
  FEDERAL_STANDARD_DEDUCTION = 24_800
  FEDERAL_RATES = { # assume married filing jointly
          0..19_750  => 0.10,
     19_750..80_250  => 0.12,
     80_250..171_050 => 0.22,
    171_050..326_600 => 0.24,
    326_600..414_700 => 0.32,
    414_700..622_050 => 0.35,
    622_050..999_999 => 0.37,
  }.freeze

  def self.calculate_federal_tax(income, num_incomes: 2)
    check_num_incomes!(num_incomes)
    income = integerize(income)

    income -= FEDERAL_STANDARD_DEDUCTION
    income -= RETIREMENT_401K_LIMIT * num_incomes

    return 0.0 if income <= 0

    rates = FEDERAL_RATES.dup
    tax = []

    raise "brackets maxed out" if income > FEDERAL_RATES.to_a.last.first.end

    while income > 0
      bracket, rate = rates.shift
      gap = bracket.end - bracket.begin
      tax << [gap, income].min * rate
      income -= gap
    end

    tax.sum
  end

  CALIFORNIA_STANDARD_DEDUCTION = 9_074
  CALIFORNIA_EXEMPTION_CREDITS = (122*2) + 378 # assume one kid
  CALIFORNIA_RATES = { # assume married filing jointly
           0_00..17_618  => 0.01,
         17_618..41_766  => 0.02,
         41_766..65_290  => 0.04,
         65_290..91_506  => 0.06,
        91_506..115_648  => 0.08,
        115_648..590_746 => 0.093,
        590_746..708_890 => 0.103,
      708_890..1_000_000 => 0.113,
    1_000_000..1_181_484 => 0.123,
    1_181_484..9_999_999 => 0.133,
  }.freeze

  def self.calculate_california_tax(income, num_incomes: 2)
    check_num_incomes!(num_incomes)

    income -= CALIFORNIA_STANDARD_DEDUCTION
    income -= RETIREMENT_401K_LIMIT * num_incomes

    return 0.0 if income <= 0

    rates = CALIFORNIA_RATES.dup
    tax = []

    raise "brackets maxed out" if income > CALIFORNIA_RATES.to_a.last.first.end

    while income > 0
      bracket, rate = rates.shift
      gap = bracket.end - bracket.begin
      tax << [gap, income].min * rate
      income -= gap
    end

    total_tax = tax.sum

    # credit child care exemption
    if total_tax > CALIFORNIA_EXEMPTION_CREDITS
      total_tax - CALIFORNIA_EXEMPTION_CREDITS
    else
      0
    end
  end

  # medicare constants
  MEDICARE_TAX_RATE = 1.45/100.0
  MEDICARE_ADDITIONAL_RATE = 0.9/100.0
  MEDICARE_ADDITIONAL_THRESHOLD = 250_000

  def self.calculate_medicare_tax(income)
    raise "negative income" if income <= 0

    base_tax = income * MEDICARE_TAX_RATE

    additional_tax = if (income < MEDICARE_ADDITIONAL_THRESHOLD)
      0
    else
      (income - MEDICARE_ADDITIONAL_THRESHOLD) * MEDICARE_ADDITIONAL_RATE
    end

    base_tax + additional_tax
  end

  # social security constants
  SOCIAL_SECURITY_MAX_WAGE = 137_700
  SOCIAL_SECURITY_TAX_RATE = 6.2/100.0

  def self.calculate_social_security_tax(income, num_incomes: 2)
    raise "negative income" if income <= 0
    raise "too many incomes" if num_incomes > 2
    raise "too few incomes" if num_incomes < 1

    income = [income, SOCIAL_SECURITY_MAX_WAGE].min
    income * SOCIAL_SECURITY_TAX_RATE * num_incomes
  end

  # AMT constants
  AMT_EXEMPTION_AMOUNT = 113_400
  AMT_PHASEOUT_THRESHOLD = 1_036_800
  AMT_HIGHER_PERCENT_RATE_THRESHOLD = 197_900

  def self.calculate_tentative_minimum_tax(amt_income)
    return 0 if amt_income < AMT_EXEMPTION_AMOUNT

    exemption_amount = if amt_income < AMT_PHASEOUT_THRESHOLD
      AMT_EXEMPTION_AMOUNT
    else
      AMT_EXEMPTION_AMOUNT - 0.25*(amt_income - AMT_PHASEOUT_THRESHOLD)
    end

    exemption_amount = 0 if exemption_amount < 0
    amt_income -= exemption_amount

    if amt_income < AMT_HIGHER_PERCENT_RATE_THRESHOLD
      amt_income * 0.26
    else
      (0.28 * amt_income) - (0.02 * AMT_HIGHER_PERCENT_RATE_THRESHOLD)
    end
  end

  def self.integerize(income)
    if income.is_a?(String)
      income.gsub(/[^\d]/, '').to_i
    else
      income
    end
  end

  def self.check_num_incomes!(num_incomes)
    raise "too many incomes" if num_incomes > 2
    raise "too few incomes" if num_incomes < 1
  end

end
