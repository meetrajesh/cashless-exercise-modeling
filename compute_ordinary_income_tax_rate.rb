# frozen_string_literal: true

# compute ordinary income rate based on income generated from exercising all grants and set it for everyone
pretax_flip_income = GRANTS.sum(&:pretax_flip_income)
nso_rsu_pretax_exercise_income = GRANTS.sum(&:nso_rsu_pretax_exercise_income)

overall_ordinary_income_tax_rate = TaxCalculators.compute_overall_tax_rate(
  FINAL_YEAR_BASE_SALARY +
  pretax_flip_income +
  nso_rsu_pretax_exercise_income
)

GRANTS.each { |g| g.overall_ordinary_income_tax_rate = overall_ordinary_income_tax_rate }

# disallow future edits to the grants
GRANTS.map(&:freeze)
