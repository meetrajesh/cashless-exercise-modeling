# frozen_string_literal: true

# ASSUME married filing jointly (MFJ)
module TaxCalculators

  def self.compute_all_taxes(income)
    {
      federal: calculate_federal_tax(income),
      state: calculate_california_tax(income),
      social_security: calculate_social_security_tax(income),
      medicare: calculate_medicare_tax(income),
    }
  end

  def self.compute_overall_tax_rate(income)
    total_tax = compute_all_taxes(income).values.sum
    total_tax / income.to_f
  end

  RETIREMENT_401K_LIMIT = 19_500  # 401k tax deductions

  # federal tax constants
  FEDERAL_STANDARD_DEDUCTION = 24_800
  FEDERAL_RATES = {
          0..19_750  => 0.10,
     19_750..80_250  => 0.12,
     80_250..171_050 => 0.22,
    171_050..326_600 => 0.24,
    326_600..414_700 => 0.32,
    414_700..622_050 => 0.35,
    622_050..999_999 => 0.37,
  }.freeze

  def self.calculate_federal_tax(income)
    income -= FEDERAL_STANDARD_DEDUCTION
    income -= RETIREMENT_401K_LIMIT * 2

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
  CALIFORNIA_EXEMPTION_CREDITS = 666.00 # assume one kid
  CALIFORNIA_RATES = {
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

  def self.calculate_california_tax(income)
    income -= CALIFORNIA_STANDARD_DEDUCTION
    income -= RETIREMENT_401K_LIMIT * 2

    rates = CALIFORNIA_RATES.dup
    tax = []

    raise "brackets maxed out" if income > CALIFORNIA_RATES.to_a.last.first.end

    while income > 0
      bracket, rate = rates.shift
      gap = bracket.end - bracket.begin
      tax << [gap, income].min * rate
      income -= gap
    end

    tax.sum - CALIFORNIA_EXEMPTION_CREDITS
  end

  # medicare constants
  MEDICARE_TAX_RATE = 1.45/100.0
  MEDICARE_ADDITIONAL_RATE = 0.9/100.0
  MEDICARE_ADDITIONAL_THRESHOLD = 250_000

  def self.calculate_medicare_tax(income)
    base_tax = income * MEDICARE_TAX_RATE
    additional_tax = (income < MEDICARE_ADDITIONAL_THRESHOLD) ? 0 : (income - MEDICARE_ADDITIONAL_THRESHOLD) * MEDICARE_ADDITIONAL_RATE

    base_tax + additional_tax
  end

  # social security constants
  SOCIAL_SECURITY_MAX_WAGE = 137_700
  SOCIAL_SECURITY_TAX_RATE = 6.2/100.0

  def self.calculate_social_security_tax(income)
    income = [income, SOCIAL_SECURITY_MAX_WAGE].min
    income * SOCIAL_SECURITY_TAX_RATE
  end

  # AMT constants
  AMT_EXEMPTION_AMOUNT = 113_400
  AMT_PHASEOUT_THRESHOLD = 1_036_800
  AMT_HIGHER_28_PERCENT_RATE_THRESHOLD = 197_900

  def self.calculate_tentative_minimum_tax(amt_income)
    return 0 if amt_income < AMT_EXEMPTION_AMOUNT

    exemption_amount = if amt_income < AMT_PHASEOUT_THRESHOLD
      AMT_EXEMPTION_AMOUNT
    else
      AMT_EXEMPTION_AMOUNT - 0.25*(amt_income - AMT_PHASEOUT_THRESHOLD)
    end

    exemption_amount = 0 if exemption_amount < 0
    amt_income -= exemption_amount

    if amt_income < AMT_HIGHER_28_PERCENT_RATE_THRESHOLD
      amt_income * 0.26
    else
      (0.28 * amt_income) - (0.02 * AMT_HIGHER_28_PERCENT_RATE_THRESHOLD)
    end
  end
end
