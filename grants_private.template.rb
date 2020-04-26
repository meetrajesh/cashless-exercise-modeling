# frozen_string_literal: true

GRANTS = [

  # NSOs vested in your final year
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.nso, strike: 1.79, num_options: 12_941),
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.nso, strike: 1.82, num_options: 2_250),
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.nso, strike: 2.45, num_options: 245),
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.nso, strike: 4.55, num_options: 4_650),
  
  # ISOs vested in your final year
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.iso, strike: 7.65, num_options: 9_535, num_flipped_rightaway: 1_500),
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.iso, strike: 10.43, num_options: 4_698),
  
  # RSUs vested in your final year
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.rsu, strike: 0, num_options: 0), # none vested
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.rsu, strike: 0, num_options: 1_234),
  StockOptionGrant.new(type: StockOptionGrant::OPTION_TYPES.rsu, strike: 0, num_options: 2_345),

].freeze


# Assume filing taxes married filing jointly
# Assume little to no base salary in the year lockup expires. ie. lockup expires early Jan or Feb,
# and then both spouses quit their jobs right after
FINAL_YEAR_BASE_SALARY = 0


