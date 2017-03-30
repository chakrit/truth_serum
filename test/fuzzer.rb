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
    vocab, stack = @vocab, []

    max = vocab.length - 1
    (min..max).each do |i|
      swap(vocab, i, min)
      stack.push([min+1, vocab.dup])
      swap(vocab, i, min)
    end

    until stack.empty?
      min, vocab = stack.pop

      max = vocab.length - 1
      if min == max
        yield vocab
      else
        (min..max).each do |i|
          swap(vocab, i, min)
          stack.push([min+1, vocab.dup])
          swap(vocab, i, min)
        end
      end
    end
  end

  def swap(arr, i, j)
    arr[i], arr[j] = arr[j], arr[i]
  end
end
