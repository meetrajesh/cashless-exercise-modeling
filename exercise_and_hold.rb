# frozen_string_literal: true
require 'memoist'

# EXERCISE AND HOLD METHODS
module ExerciseAndHold
  extend Memoist

  def total_cost_to_exercise_with_taxes
    return 0 if num_options_exercised_and_held == 0
    pretax_exercise_cost + tax_on_exercise_and_hold
  end

  def num_options_exercised_and_held
    @num_options - @num_options_sold_immediately_on_exercise
  end
  memoize :num_options_exercised_and_held

  def pretax_exercise_cost
    @strike * num_options_exercised_and_held
  end

  def bargain_element
    num_options_exercised_and_held * option_value
  end

  def income_for_amt_calculation
    # same for both iso's and nso's
    bargain_element
  end

  def exercise_time_value_of_options
    bargain_element
  end

  def value_of_exercised_and_held_shares
    num_options_exercised_and_held * @exercise_time_fmv
  end

  def tax_on_exercise_and_hold
    nso_rsu_pretax_exercise_income * @overall_ordinary_income_tax_rate
  end

  def nso_rsu_pretax_exercise_income
    if iso?
      0 # assume 0 for now and calculate AMT across all grants later
    elsif nso? || rsu?
      bargain_element
    end
  end
end
