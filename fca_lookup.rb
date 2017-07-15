require 'watir'
require "watir/wait"
require "./company_house.rb"



class FCAlookup
  @@b = Watir::Browser.new :chrome
  def initialize(key)
    @keyword = key
    # initiliase the Browser
    @@b.goto'https://register.fca.org.uk/'

    # enter the keyword and search
    t = @@b.text_field id: 'j_id0:j_id1:j_id33:j_id34:registersearch:j_id36:searchBox'
    t.set @keyword
    btn = @@b.button value: 'Search the Register'
    btn.click

    # create page listing for 500 accnt
    @@b.select_list(:name, "SearchResults_length").select_value("500")
  end

  def changing_page(pagelink)
    # for pages 2 or more click the button.
    if pagelink.to_i > 1
      pg = @@b.link css: "#SearchResults_paginate > span > a:nth-child(#{pagelink})"
      pg.click
    end
  end

  def get_results(keyword,pagelink)
    # lets walk the results and save it to a file
    tb = @@b.table :id, 'SearchResults'

    c = Company.new()

    # lets create the file.
    f = File.new("table-#{@keyword}-#{pagelink}.txt",  'w+')

    tb.trs.each do |trd|
      trd.tds(class: 'ResultName').each do |td|
        b2 = Watir::Browser.start "#{td.a.href}"
        if b2.span(:class => 'statusbox').exists? && b2.span(:class => 'statusbox').inner_html == 'See full details'
          if b2.span(:id=> 'j_id0:j_id1:j_id110:j_id252').div(:class => 'FirmBasicDetailsSection').p.exists?
            cid = b2.span(:id=> 'j_id0:j_id1:j_id110:j_id252').div(:class => 'FirmBasicDetailsSection').p.inner_html
          end
          if b2.span(:id=> 'j_id0:j_id1:j_id110:j_id286').div(:class => 'FirmBasicDetailsSection').p.b.exists?
            type = b2.span(:id=> 'j_id0:j_id1:j_id110:j_id286').div(:class => 'FirmBasicDetailsSection').p.b.inner_html
          end
          if b2.span(:id=> 'j_id0:j_id1:j_id110:j_id296').exists?
            date = b2.span(:id=> 'j_id0:j_id1:j_id110:j_id296').inner_html
          end
          if b2.span(:id=> 'j_id0:j_id1:j_id110:j_id300').exists?
            status = b2.span(:id=> 'j_id0:j_id1:j_id110:j_id300').inner_html
          end

          linktxt = td.a.inner_html

          if type == 'Authorised Payment Institution'
            out = c.get_record(cid)
            out['fca'] = td.a.href
            out['type'] = type
            out['status'] = status
            f.print out.values.map{|e|"#{e}"}.join(';')
          end

          # f.print "#{linktxt}\t#{td.a.href}\t#{cid}\t#{type}\t#{date}\t#{status}"
        end
        b2.close
      end
      f.print "\n"
    end
    f.close
  end
end

# setup the default value
keyword =  ARGV[0] ? ARGV[0] : 'transfer'
# clicknextpg
pagelink = ARGV[1] ? ARGV[1] : 1

f  = FCAlookup.new(keyword)
f.changing_page(pagelink)
f.get_results(keyword,pagelink)
