import math, tables

#this  code is a copy or inspiration of "https://github.com/chrisjchandler/entropy/blob/main/entropy.go"
proc calculateEntropy*(input: string): float = 
  #count the frequency of each char
  var frequency = initCountTable[char]()
  for ch in input:
    frequency.inc(ch)

  #calculate the total number of characters
  let total = input.len.float
  #caluclate entropy
  var entropy: float = 0.0
  for _, count in frequency:
    let probability = count.float/total
    entropy += probability * log2(probability)

  #negate the sum as entropy is positive
  return -entropy

proc minimumEntropy*(input: string, minEnt: float): bool
  return calculateEntropy(input) >= minEnt