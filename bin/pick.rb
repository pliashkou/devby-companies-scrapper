# encoding: utf-8
require 'roo'
require 'mechanize'


COMPANIES_PAGE = 'https://companies.dev.by/'

agent = Mechanize.new

agent.get(COMPANIES_PAGE) do |page|
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
      break if location_section.nil?
      address_span = location_section.at('.street-address')
      address = address_span.text unless address_span.nil?
    end


    company_page.search('.widget-companies-agents li').each do |representative|
      rep_fullname = representative.at('i.icon-dev-hr + a').text

      email_link = representative.at('.a-link')
      rep_email    = email_link.nil? ? nil : email_link.text

      rep_name = representative.at('strong').text
      rep_position = representative.at('strong + span').text

      phone_span = representative.at(':last-child span')
      phone = phone_span.nil? ? nil : phone_span.text
    end
  end
end
