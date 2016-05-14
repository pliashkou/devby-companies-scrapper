# encoding: utf-8
require 'roo'
require 'mechanize'


COMPANIES_PAGE = 'https://companies.dev.by/'

agent = Mechanize.new

titles = []

agent.get(COMPANIES_PAGE) do |page|
  require 'pry'; binding.pry
  page.search('.companies tbody tr').each do |tr|
    title_link = tr.at('td:first-of-type a')
    title          = title_link.text
    employee_count = tr.at('td:nth-of-type(3)')['data']

    company_page = agent.click(title_link)


    website, phone = nil, nil
    company_page.at('.sidebar-views-contacts').tap do |contacts_section|
      email_link =  contacts_section.at('.email')
      email = email_link.nil? ? nil : email_link.text

      contacts_section.search('li').each do |li|
        case li.text
        when /Телефон/ then phone   = li.at('span').text
        when /Сайт/    then website = li.at('a').text
        end
      end
    end

    address = nil
    company_page.at('.info-ofice').tap do |location_section|
      address_span = location_section.at('.street-address')
      address = address_span.text unless address_span.nil?
    end




  end
end
