#
#
#
#
# a = 0
# b = 1
# c = 2
# d = 3
# e = 4
# f = 5
#
#
# e = b * d
# if e == f
#
#
#
#
#
# 3 is e = b * d
# 4 followed by 5 is kinda:
# if e == f
#   skip 6, do 7, which is
#   a = a + b
# else
#   6 is skip 7, do 8, which is
#   d += 1
# end
#
# 9, 10 is
# if d > f
#   12, which is
# else
#   3, the start of this loop
# end
#
# 12 is b += 1
#
# 13, 14
# if b > e
#   15 which is go to 2
# else
#   16
# end
#
#
#
#

(a,b,c,d,e,f) = %w{0 0 0 0 0 0}.map(&:to_i)


def seventeen
  # not entirely true because these are all relative values, but this only ever gets called once so it's fine
  if a == 1
    (a, b, d, e, f) = [0, 0, 0, 10550400, 10551355]
  else
    (a, b, d, e, f) = [0, 0, 0, 119, 955]
  end
  # this controls how long the program runs
end

#   if a == 1
#   e += 2 # 17
#   e *= e # 18
#   e *= c # 19, and since c can only be 19 here ever, since it's our instruction pointer, this is e *= 19
#   e *= 11 # 20
#   d += 5 # 21
#   d *= c # 22, and since c ... d *= 22
#   d += 9 # 23
#   e += d # 24
#
#   require 'pry'
#   binding.pry
#
#   if a == 1 # 25 c = c + a a starts off as a flag for execution
#     # 27
#     e = c # 27, setr 2 _ 4, 2 can only be 27 here, so e = 27, effectively
#     e *= c # 28, e *= 28 effectively, since c can only be 28 here
#     e += c # 29, e += 29
#     e *= c # 30, e *= 30
#     e *= 14 # 31
#     e *= c # 32 e *= 32
#     e += f # 33
#     a = 0 # 34
#     # 35 -> goto 1, exit function
#   else
#     # 26 -> goto 1, exit function
#   end
# end



seventeen
# 0 ->  goto 17, I think this is effectively a function call # 0

b = 1 # 1

loop do
  d = 1 # 2

  loop do
    e = b * d # 3
    if e == f # 4/5
      a = a + b
    else
      # 6 go to 8
    end

    d += 1 # 8

    if d > f #9 10
      break # 11 says goto 12
    end
  end # 11 says goto 3

  b += 1 # 12
  if b > e # 13,14
    c *= c # 16, and since 'c' is our function pointer, and it's set to 16 here, this sets it to 256, so this is the end of the program
  end
end # 15, from 13,14, says goto 2
