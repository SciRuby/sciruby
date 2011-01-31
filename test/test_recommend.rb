require(File.expand_path(File.dirname(__FILE__)+'/helpers_tests.rb'))

class TestRecommend < MiniTest::Unit::TestCase
  context(SciRuby::Recommend::SetDistance) do
    setup do
      @a, @b, @total = [1,3,5,6], [5,6,7,9], 10000
      @hypg = SciRuby::Recommend::SetDistance.new(@a, @b, @total, :hypergeometric)
    end
    should "return correct value for distance with hypergeometric as default" do
      assert_in_delta 7.19879956756486e-07, @hypg.distance, 0.00001
    end
    should "return correct value for distance_pearson" do
      assert_in_delta 0.500200080032013, @hypg.distance_pearson, 0.00001
    end
  end
end