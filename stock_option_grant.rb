# frozen_string_literal: true

require 'memoist'
require 'ostruct'

require './exercise_and_hold.rb'
require './final_sale_ltcg.rb'
require './exercise_and_sell_flip.rb'
require './tax_calculators.rb'

class StockOptionGrant
  extend Memoist
  include ExerciseAndHold
  include FinalSaleLTCG
  include ExerciseAndSellFlip

  EXERCISE_TIME_FMV = 29.74
  FINAL_SELL_PRICE = 65.00
  
  OVERALL_ORDINARY_INCOME_TAX_RATE = 39.31/100.0
  ISO_FLIP_MEDICARE_DISCOUNT = 2.35/100.0

  AMT_TAX_RATE = 28.0/100.0 # 28%

  OPTION_TYPES = OpenStruct.new(
    iso: 'iso',
    nso: 'nso',
    rsu: 'rsu',
  ).freeze

  attr_reader :type, :num_options, :num_options_sold_immediately_on_exercise, :exercise_time_fmv
  attr_accessor :overall_ordinary_income_tax_rate

  def initialize(type:, strike:, num_options:, num_flipped_rightaway: nil, exercise_time_fmv: nil)
    @type = type
    @strike = strike
    @num_options = num_options
    @num_options_sold_immediately_on_exercise = num_flipped_rightaway || default_num_options_flipped_rightaway
    @exercise_time_fmv = exercise_time_fmv || EXERCISE_TIME_FMV

    raise "RSU with non-zero strike" if rsu? && @strike > 0
    raise "too many options sold" if @num_options_sold_immediately_on_exercise > @num_options
    raise "bad type: #{type.inspect}" if !OPTION_TYPES.to_h.values.include?(type)
  end

  def option_value
    @exercise_time_fmv - @strike
  end
  memoize :option_value

  def pretax_option_value
    option_value * @num_options
  end

  def iso?
    @type == OPTION_TYPES.iso
  end

  def nso?
    @type == OPTION_TYPES.nso
  end

  def rsu?
    @type == OPTION_TYPES.rsu
  end

end