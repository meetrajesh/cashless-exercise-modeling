# frozen_string_literal: true

def cur(amount)
  "$" + num(amount.round)
end

def num(number)
  tmp = number.abs.to_s.chars.reverse.each_slice(3).to_a.reverse.map(&:reverse).map(&:join).join(',')
  tmp = "-#{tmp}" if number < 0
  tmp
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