require 'test_helper'

module TruthSerum
  LEX_TESTS = {
    'word'          => [:term, 'word'],
    'space  space'  => [:term, 'space', :space, '  ', :term, 'space'],
    '::++--'        => [:colon, ':', :colon, ':', :plus, '+', :plus, '+', :minus, '-', :minus, '-'],
    '"quote"'       => [:term, 'quote'],
    '"unended'      => [:term, 'unended'],
    'ending"'       => [:term, 'ending'],
    'mid"dle'       => [:term, 'middle'],
    '"space quote"' => [:term, 'space quote'],
    '":sym+quote-"' => [:term, ':sym+quote-'],
    'split:split'   => [:term, 'split', :colon, ':', :term, 'split'],
    '-a:b+a:b'      => [:minus, '-', :term, 'a', :colon, ':', :term, 'b', :plus, '+', :term, 'a', :colon, ':', :term, 'b'],
    '"\r\n\a\b\""'  => [:term, "\r\nab\""],
    'a:b b'         => [:term, 'a', :colon, ':', :term, 'b', :space, ' ', :term, 'b'],
    'a "b b"'       => [:term, 'a', :space, ' ', :term, 'b b'],
    '-a+ "h h"-'    => [:minus, '-', :term, 'a', :plus, '+', :space, ' ', :term, 'h h', :minus, '-'],
    '-"\r :"zxcv'   => [:minus, '-', :term, "\r :", :term, 'zxcv'],
  }

  PARSE_TESTS = {
    'asdf'         => { terms: ['asdf'] },
    '-asdf'        => { negative_terms: ['asdf'] },
    '"quote"'      => { terms: ['quote'] },
    '-"quote"'     => { negative_terms: ['quote'] },
    'a:b'          => { filters: { 'a' => 'b' } },
    '-a:b'         => { negative_filters: { 'a' => 'b' } },
    '"s s":"x x"'  => { filters: { 's s' => 'x x' } },
    'term a:b'     => { terms: ['term'], filters: { 'a' => 'b' } },
    '-term-a:b'    => { negative_terms: ['term'], negative_filters: { 'a' => 'b' } },
    'a::::b'       => { filters: { 'a' => ':::b' } },
    'a:bb:c'       => { filters: { 'a' => 'bb:c' } },
    'a:2016-01-02' => { filters: { 'a' => '2016-01-02' } },
  }

  UNPARSE_TESTS = {
    'asdf'         => { terms: ['asdf'] },
    '-asdf'        => { negative_terms: ['asdf'] },
    '"a b"'        => { terms: ['a b'] },
    'a:b'          => { filters: { 'a' => 'b' } },
    '-a:b'         => { negative_filters: { 'a' => 'b' } },
    '"s s":"x x"'  => { filters: { 's s' => 'x x' } },
    'term a:b'     => { terms: ['term'], filters: { 'a' => 'b' } },
    '-term -a:b'   => { negative_terms: ['term'], negative_filters: { 'a' => 'b' } },
    'a::::b'       => { filters: { 'a' => ':::b' } },
    'a:bb:c'       => { filters: { 'a' => 'bb:c' } },
    'a:2016-01-02' => { filters: { 'a' => '2016-01-02' } },
  }
end
