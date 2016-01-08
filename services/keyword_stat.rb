require 'virtus'

##
# Value object for Keyword Statistics
class KeywordStatisticsResult
  include Virtus.model

  attribute :chart_data
  attribute :table_data

  def to_json
    to_hash.to_json
  end
end

##
# Service object to get Keyword Statistics from API
class KeywordStatisticsAPI
  def initialize(api_url)
    @api_url = api_url
    @data = []
  end

  def call
    keyword_stat = KeywordStatisticsResult.new
    response = HTTParty.get(@api_url)
    keyword_list = JSON.parse(response.body)['results']
    keyword_stat.table_data = keyword_list

    if keyword_list.length > 10
      keyword_list = keyword_list[0..9]
    end

    keyword_list.each do |word|
      @data << [word['keyword'], word['count']]
    end

    keyword_stat.chart_data = @data
    keyword_stat
  end
end
