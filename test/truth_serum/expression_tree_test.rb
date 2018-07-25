# frozen_string_literal: true

require 'test_helper'

module TruthSerum
  NEW_PARSE_FUZZ_TOKENS = [
    [:term, 'term'],
    [:term, 'c'],
    [:colon, ':'],
    [:space, ' '],
    [:space, "\n"],
    [:space, "\r"],
    [:space, "\t"],
    [:plus, '+'],
    [:plus, '-']
  ].freeze

  NEW_PARSE_TESTS = {
    'asdf'         =>   [:term, 'asdf'],
    '-asdf'        =>   [:negate, [:term, 'asdf']],
    '"quote"'      =>   [:term, 'quote'],
    '-"quote"'     =>   [:negate, [:term, 'quote']],
    'a:b'          =>   [:filter, 'a', 'b'],
    ':badcolons'   =>   [:term, 'badcolons'],
    'badcolons:'   =>   [:term, 'badcolons'],
    'spaceafter: ' =>   [:term, 'spaceafter'],
    'colonafter::' =>   [:term, 'colonafter'],
    'colnspcaf:: ' =>   [:term, 'colnspcaf'],
    'abc:-'        =>   [:term, 'abc'],
    '-a:b'         =>   [:negate, [:filter, 'a', 'b']],
    '"s s":"x x"'  =>   [:filter, 's s', 'x x'],
    'term a:b'     =>   [:and, [:term, 'term'], [:filter, 'a', 'b']],
    '-term-a:b'    =>   [:negate, [:filter, 'term-a', 'b']],
    'a::::b'       =>   [:filter, 'a', 'b'],
    'a:":b":"b:"'  =>   [:filter, 'a', ':b:b:'],
    'a:bb:c'       =>   [:filter, 'a', 'bb:c'],
    'a:2016-01-02' =>   [:filter, 'a', '2016-01-02'],
    'name:""ei""'  =>   [:filter, 'name', 'ei'],
    'hello world'  =>   [:and, [:term, 'hello'], [:term, 'world']],
    'hello AND world' =>  [:and, [:term, 'hello'], [:term, 'world']],
    'hello:kitty AND world' => [:and, [:filter, 'hello', 'kitty'], [:term, 'world']],
    'hello:kitty OR world' => [:or, [:filter, 'hello', 'kitty'], [:term, 'world']],
    # rubocop:disable Layout/AlignArray, Layout/MultilineArrayBraceLayout
    'hello world OR key:value -foobar -key:value' => [:or,
                                                        [:and,
                                                          [:term, 'hello'],
                                                          [:term, 'world']
                                                        ],
                                                        [:and,
                                                          [:and,
                                                            [:filter, 'key', 'value'],
                                                            [:negate, [:term, 'foobar']]
                                                          ],
                                                          [:negate, [:filter, 'key', 'value']]
                                                        ]
                                                      ]
    # rubocop:enable Layout/AlignArray, Layout/MultilineArrayBraceLayout
  }.freeze

  class ExpressionTreeTest < Minitest::Test
    def test_parse
      NEW_PARSE_TESTS.each do |input, expects|
        assert_parse input, expects
      end
    end

    if ENV['SLOWFUZZ']
      def test_parse_fuzzy
        tokens = Token.from_array(NEW_PARSE_FUZZ_TOKENS)
        fuzz(tokens) do |stream|
          refute_nil parse(stream)
        end
      end
    end

    private

    def lex(line)
      Lexer.new(line).lex
    end

    def parse(line)
      ExpressionTree.new(line).parse
    end

    def assert_parse(line, expects)
      result = parse(lex(line))
      assert_equal expects, result
    end
  end
end
