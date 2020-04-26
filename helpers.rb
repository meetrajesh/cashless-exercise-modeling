# frozen_string_literal: true

def cur(amount)
  "$" + num(amount.round)
end

def num(number)
  number.to_s.chars.reverse.each_slice(3).to_a.reverse.map(&:reverse).map(&:join).join(',')
end

class Array
  def sum(&proc)
  	if proc
  	  map(&proc).inject(&:+)
    else
      inject(&:+)
    end
  end
end