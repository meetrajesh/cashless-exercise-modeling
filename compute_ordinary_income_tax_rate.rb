# frozen_string_literal: true

# compute ordinary income rate based on income generated from exercising all grants and set it for everyone
pretax_flip_income = GRANTS.sum(&:pretax_flip_income)
nso_rsu_pretax_exercise_income = GRANTS.sum(&:nso_rsu_pretax_exercise_income)

stock_income = pretax_flip_income + nso_rsu_pretax_exercise_income
extra_taxes_due_to_stock = TaxCalculators.compute_overall_taxes(FINAL_YEAR_BASE_SALARY + stock_income) - TaxCalculators.compute_overall_taxes(FINAL_YEAR_BASE_SALARY)
overall_ordinary_income_tax_rate = extra_taxes_due_to_stock / stock_income.to_f

GRANTS.each { |g| g.overall_ordinary_income_tax_rate = overall_ordinary_income_tax_rate }

# disallow future edits to the grants
GRANTS.map(&:freeze)
