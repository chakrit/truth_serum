require "truth_serum/version"
require "truth_serum/result"
require "truth_serum/token"
require "truth_serum/lexer"
require "truth_serum/parser"

module TruthSerum
  def self.parse(line)
    Result.new(**Parser.new(Lexer.new(line).lex).parse)
  end
end
