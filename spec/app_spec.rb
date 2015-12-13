require_relative 'spec_helper'
require 'json'

describe 'Kiwi orchard Stories' do
  include PageObject::PageFactory
  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
  end

  describe 'Visiting the home page' do
    it 'finds the title' do
      visit HomePage do |page|
        page.title.must_equal 'Kiwi orchard'
        page.home_link_element.exists?.must_equal true
        page.kiwi_learn_link_element.exists?.must_equal true
        page.search_link_element.exists?.must_equal true
        page.courses_link_element.exists?.must_equal true
        page.statistics_link_element.exists?.must_equal true
      end
    end

    it 'check home page' do
      visit HomePage do |page|
        page.click_home_link
        page.homepage_header.must_equal 'Hello, welcome to Kiwi Orchard!!'

        page.click_kiwi_learn_link
        page.homepage_header.must_equal 'Hello, welcome to Kiwi Orchard!!'
      end
    end

  end

  describe 'Search a course' do
    it 'can search a course' do

      visit SearchPage do |page|
        page.browser.url.must_match %r{http.*/search}
        page.search_header.must_equal 'Search a course with keyword'

        # GIVEN & WEHN
        page.search_course('program')

        # THEN
        page.browser.url.must_match %r{http.*/search}
        page.number_of_courses_shown.must_be :>=, 1

      end
    end
  end

  describe 'List all courses' do
    it 'check courses list page and table' do
      # GIVEN
      visit CoursePage do |page|
        # WHEN
        # THEN
        page.browser.url.must_match %r{http.*/courses}
        page.number_of_courses_shown.must_be :>=, 200
      end

    end
  end

  describe 'Show courses history statistics' do
    it 'check statistics page and header' do
      # GIVEN
      visit StatisticsPage do |page|
        # WHEN
        # THEN
        page.browser.url.must_match %r{http.*/statistics}
        page.statistics_header.must_equal 'Courses History Statistics'
        page.chart_2015_element.exists?.must_equal true
        page.chart_2014_element.exists?.must_equal true
        page.chart_2013_element.exists?.must_equal true
        page.chart_2012_element.exists?.must_equal true
      end

    end
  end

  after do
    @browser.close
    # @headless.destroy
  end
end
