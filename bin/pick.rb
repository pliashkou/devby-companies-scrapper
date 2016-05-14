require 'roo'
require 'mechanize'


COMPANIES_PAGE = 'https://companies.dev.by/'

agent = Mechanize.new

titles = []

agent.get(COMPANIES_PAGE) do |page|
  page.search('.companies tbody tr').each do |tr|
    title_link = tr.at('td:first-of-type a')
    title          = title_link.text
    employee_count = tr.at('td:nth-of-type(3)')['data']
  end
end
