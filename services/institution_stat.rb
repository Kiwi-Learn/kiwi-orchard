require 'virtus'

##
# Value object for results from searching a tutorial set for missing badges
class InstitutionsStatisticsResult
  include Virtus.model

  attribute :top10_data

  def to_json
    to_hash.to_json
  end
end

##
# Service object to get Courses Date Statistics from API
class InstitutionsStatisticsResultAPI
  def initialize(api_url)
    @api_url = api_url

    @institution_stat = Hash.new{|h,k| h[k] = 0}
  end

  def call
    institution_stat = InstitutionsStatisticsResult.new
    results = HTTParty.get(@api_url)
    courses = JSON.parse(results.body)

    courses.each do |result|
      institution = result['institution']

      #set default
      if @institution_stat.has_key?(institution)
        @institution_stat[institution]
      end

      @institution_stat[institution] += 1
    end
    @institution_stat.delete("None")
    @institution_stat = @institution_stat.sort_by{|k,v| v}.reverse

    institution_stat.top10_data = @institution_stat[0..9]
    institution_stat
  end
end
