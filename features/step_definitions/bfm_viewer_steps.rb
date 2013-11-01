require 'watir-webdriver'

Before do
	@b = Watir::Browser.new :ff
end

After do
	#@b.close
end

Given(/^I am in the BFM Viewer$/) do
  @b.goto "localhost:9393"
end

When(/^I click on the East link in (\d+)$/) do |arg1|
  l = @b.link :text => '11026'
  l.click
end

Then(/^I should go to (\d+)$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end
