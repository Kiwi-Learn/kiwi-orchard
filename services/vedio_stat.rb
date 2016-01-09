require 'virtus'

##
# Value object for Keyword Statistics
class VedioStatisticsResult
  include Virtus.model

  attribute :chart_data

  def to_json
    to_hash.to_json
  end
end

##
# Service object to get Keyword Statistics from API
class VedioStatisticsAPI
  def initialize(api_url)
    @api_url = api_url
    @data = []
  end

  def call
    video_stat = VedioStatisticsResult.new
    response = HTTParty.get(@api_url)

    if response.code === 204
      video_stat.chart_data = []
      return video_stat
    end

    video_stat.chart_data = JSON.parse(response.body)['results']

    video_stat
  end
end
