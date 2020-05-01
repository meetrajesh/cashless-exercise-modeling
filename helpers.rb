# frozen_string_literal: true

def cur(amount)
  "$" + num(amount.round)
end

def num(number)
  tmp = number.abs.to_s.chars.reverse.each_slice(3).to_a.reverse.map(&:reverse).map(&:join).join(',')
  tmp = "-#{tmp}" if number < 0
  tmp
end

def print_paragraph(paragraph, max_chars_per_line=75)
  cur_chars = 0
  paragraph.gsub("\n", ' ').split(/\s+/).each do |word|
    if (cur_chars + word.length) < max_chars_per_line
      print word + ' '
      cur_chars += word.length
    else
      puts
      print word + ' '
      cur_chars = word.length
    end
  end
  puts
  puts
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

class String
  def titleize
    split(/[^a-z]+/i).map(&:capitalize).join(' ')
  end
end
