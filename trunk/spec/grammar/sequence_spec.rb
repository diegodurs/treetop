require 'rubygems'
require 'spec'

dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

context "The result of a sequence parsing expression with one element, when that element parses successfully" do
  setup do
    @element = mock("Parsing expression in sequence")
    @elt_result = successful_parse_result
    @elt.stub!(:parse_at).and_return(@elt_result)
    @sequence = Sequence.new([@elt])
    @result = @sequence.parse_at(mock('input'), 0, parser_with_empty_cache_mock)    
  end
      
  specify "returns a SuccessfulParseResult with a SequenceSyntaxNode value with the element's parse result as an element if the parse is successful" do    
    @result.should be_success
    @result.should be_a_kind_of(SequenceSyntaxNode)
    @result.elements.should == [@elt_result]
  end  
end

context "A sequence parsing expression with multiple terminal symbols as elements" do
  setup do
    @elts = ["foo", "bar", "baz"]
    @sequence = Sequence.new(@elts.collect { |w| TerminalSymbol.new(w) })
  end
  
  specify "returns a successful result with correct elements when matching input is parsed" do
    input = @elts.join
    index = 0
    result = @sequence.parse_at(input, index, parser_with_empty_cache_mock)
    result.should be_success
    result.elements.collect(&:text_value).should == @elts
    result.interval.end.should == index + input.size
  end
  
  specify "returns a successful result with correct elements when matching input is parsed when starting at a non-zero index" do
    input = "----" + @elts.join
    index = 4
    result = @sequence.parse_at(input, index, parser_with_empty_cache_mock)
    result.should be_success
    result.elements.collect(&:text_value).should == @elts
    result.interval.end.should == index + @elts.join.size
  end
  
  specify "has a string representation" do
    @sequence.to_s.should == '("foo" "bar" "baz")'
  end
end

context "The result of a sequence parsing expression with one element and a method defined in its node class" do
  setup do
    @elt = mock("Parsing expression in sequence")
    @elt_result = successful_parse_result
    @elt.stub!(:parse_at).and_return(@elt_result)

    @sequence = Sequence.new([@elt])
    @sequence.node_class_eval do
      def method
      end
    end
    
    @result = @sequence.parse_at(mock('input'), 0, parser_with_empty_cache_mock)
  end
  
  specify "has a value that is a kind of of SequenceSyntaxNode" do
    @result.should be_a_kind_of(SequenceSyntaxNode)
  end
  
  specify "responds to the method defined in the node class" do
    @result.should respond_to(:method)
  end
end

context "The result of a sequence parsing expression with one element and a method defined in its node class via the evaluation of a string" do
  setup do
    @elt = mock("Parsing expression in sequence")
    @elt_result = successful_parse_result
    @elt.stub!(:parse_at).and_return(@elt_result)

    @sequence = Sequence.new([@elt])
    @sequence.node_class_eval %{
      def method
      end
    }
    
    @result = @sequence.parse_at(mock('input'), 0, parser_with_empty_cache_mock)
  end
  
  specify "has a value that is a kind of of SequenceSyntaxNode" do
    @result.should be_a_kind_of(SequenceSyntaxNode)
  end
  
  specify "responds to the method defined in the node class" do
    @result.should respond_to(:method)
  end
end

context "The parse result of a sequence of two terminals when the second fails to parse" do
  setup do
    @terminal_1 = TerminalSymbol.new('{')
    @terminal_2 = TerminalSymbol.new('}')
    @sequence = Sequence.new([@terminal_1, @terminal_2])
    
    @index = 0
    
    @result = @sequence.parse_at('{x', @index, parser_with_empty_cache_mock)
  end
  
  specify "is itself a failure" do
    @result.should be_a_failure
  end
  
  specify "has an index equivalent to the start index of the parse" do
    @result.index.should == @index
  end  
end