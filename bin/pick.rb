# encoding: utf-8
require 'simple_xlsx'
require 'mechanize'
require 'csv'

COMPANIES_PAGE = 'https://companies.dev.by/'

companies = []

agent = Mechanize.new
agent.get(COMPANIES_PAGE) do |page|
  page.search('.companies tbody tr').each do |tr|
    company = {}

    title_link  = tr.at('td:first-of-type a')
    company[:title] = title_link.text
    company[:employees_count] = tr.at('td:nth-of-type(3)')['data']

    company_page = agent.click(title_link)

    website, phone = nil, nil
    company_page.at('.sidebar-views-contacts').tap do |contacts_section|
      email_link =  contacts_section.at('.email')
      email = email_link.nil? ? nil : email_link.text

      contacts_section.search('li').each do |li|
        case li.text
        when /Телефон/ then company[:phone]   = li.at('span').text
        when /Сайт/    then company[:website] = li.at('a').text
        end
      end
    end

    company_page.at('.info-ofice').tap do |location_section|
      break if location_section.nil?
      address_span = location_section.at('.street-address')
      company[:address] = address_span.text unless address_span.nil?
    end

    representatives = []
    company_page.search('.widget-companies-agents li').each do |r|
      representative = {}
      representative[:fullname] = r.at('i.icon-dev-hr + a').text

      r.at('.a-link') do |email_link|
        representative[:email] = email_link.nil? ? nil : email_link.text
      end

      representative[:name]     = r.at('strong').text
      representative[:position] = r.at('strong + span').text

      r.at(':last-child span') do |phone_span|
        representative[:phone] = phone_span.nil? ? nil : phone_span.text
      end
      representatives << representative
    end
    company[:representatives] = representatives

    companies << company
  end
end

str = CSV.generate do |csv|
  companies.each do |company|
    info = company.values_at(:name, :employees_count, :website, :email, :address, :phone)
    unless company[:representatieves].nil?
      info << company[:representatieves].map { |r| r.values_at(:fullname, :position, :email, :phone) }.flatten
    end
    info.map! { |a| a ? a.gsub("\n", '') : nil }
    csv << info
  end
end
File.write('test.csv', str)
