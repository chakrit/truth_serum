# frozen_string_literal: true
class Fuzzer
  def initialize(vocab)
    @vocab = vocab.dup
  end

  def fuzz
    permute 0 do |line|
      yield line
    end
  end

  private

  def permute(min, &block)
    max = @vocab.length - 1
    if min == max
      yield @vocab
      return
    end

    (min..max).each do |i|
      swap(@vocab, i, min)
      permute(min + 1, &block)
      swap(@vocab, i, min)
    end
  end

  def swap(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i]
  end
end
