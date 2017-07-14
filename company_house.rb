require 'yaml'

# https://app.creditsafeuk.com/CSUKLive/WebPages/Login.aspx
# https://app.creditsafeuk.com/CSUKLive/webpages/CompanySearch/CompanySummary.aspx?CompanyNumber=04741528
class Company
@@b = Watir::Browser.new :chrome
  def initialize()
    # load the credentials from file
    config =  YAML.load_file('credentials.yml')
    @@b.goto 'https://app.creditsafeuk.com/CSUKLive/WebPages/Login.aspx'
    @@b.text_field(id: 'txtUserName').set(config['user'])
    @@b.text_field(id: 'txtPassword').set(config['password'])
    @@b.link(:id =>"btnLogin").click
  end

  def get_record(cid)
    @@b.goto "https://app.creditsafeuk.com/CSUKLive/webpages/CompanySearch/CompanySummary.aspx?CompanyNumber=#{cid}"

    contract_limit = @@b.span(:id => 'ctl00_MainContent_Dashboard__lblCompanyContractLimit')
    contract_limit = contract_limit.exists? ? contract_limit.inner_html : "-"

    credit_limit = @@b.span(:id => 'ctl00_MainContent_Dashboard__lblCompanyCurrentLimit')
    credit_limit = credit_limit.exists? ? credit_limit.inner_html : "-"

    company_debt = @@b.span(:id => 'ctl00_MainContent_Dashboard__lblCompanyDBT')
    company_debt = company_debt.exists? ? company_debt.inner_html : "-"

    industry_debt = @@b.span(:id => 'ctl00_MainContent_Dashboard__lblCompanyIndustryDBT')
    industry_debt = industry_debt.exists? ? industry_debt.inner_html : "-"

    company_status = @@b.span(:id => 'ctl00_MainContent_Dashboard__lblCompanyStatus')
    company_status = company_status.exists? ? company_status.inner_html : "-"

    company_rating = @@b.a(:id => 'ctl00_MainContent_Dashboard__lblCompanyRating')
    company_rating = company_rating.exists? ? company_rating.inner_html : "-"

    company_website = @@b.a(:id => 'ctl00_MainContent_CompanySummary1_hlWebsiteAddress')
    company_website = company_website.exists? ? company_website.inner_html : "-"

    last_financial = @@b.span(:id => 'ctl00_MainContent_CompanySummary1__lblLastKeyFinancialsShareholder')
    last_financial= last_financial.exists? ? last_financial.inner_html : "-"

    c0 = @@b.span(:id => 'ctl00_MainContent_Commentary_CommentaryRepeater_ctl00_commentaryLabel')
    c1 = @@b.span(:id => 'ctl00_MainContent_Commentary_CommentaryRepeater_ctl01_commentaryLabel')
    c2 = @@b.span(:id => 'ctl00_MainContent_Commentary_CommentaryRepeater_ctl02_commentaryLabel')
    c3 = @@b.span(:id => 'ctl00_MainContent_Commentary_CommentaryRepeater_ctl03_commentaryLabel')
    c4 = @@b.span(:id => 'ctl00_MainContent_Commentary_CommentaryRepeater_ctl04_commentaryLabel')
    comments  =  c0.exists? ? c0.inner_html + " " : '';
    comments += c1.exists? ? c1.inner_html + " " : '';
    comments += c2.exists? ? c2.inner_html + " " : '';
    comments += c3.exists? ? c3.inner_html + " " : '';
    comments += c4.exists? ? c4.inner_html + " " : '';

    company_house = "https://beta.companieshouse.gov.uk/company/#{cid}"
    company_id = cid

    company_name = @@b.span(:id => 'ctl00_MainContent_PrintSaveCompanyNameBar1_lblCompanyNameResult')
    company_name = company_name.exists? ? company_name.inner_html : "-"

  return "#{company_name}\t#{company_id}\t#{company_house}\t#{company_rating}\t#{credit_limit}\t#{contract_limit}\t#{company_status}\t#{company_debt}\t#{industry_debt}\t#{last_financial}\t#{company_website}\t#{comments}\n"
  end
end

# # lets create the file to dump our dattainto
# f = File.new("creditsafecheck.txt",  'w+')
#
# cids = ["4363859","3538207","6869858","4741528","NI065249","5108236","6401266","5559143","6123808","5696336","3786396","5237898","SC300349","6640668","6692184","5819737","7952651","7619383","7914165","6302237","6872129","7379137","7179911","6863028","9377714","9171042","9627585","9660828","9370840","6063185"]
# c = Company.new()
# f.print "company_name\tcompany_id\tcompany_house\tcompany_rating\tcredit_limit\tcontract_limit\tcompany_status\tcompany_debt\tindustry_debt\tlast_financial\tcompany_website\tcomments\n"
# cids.each do |cid|
#   if cid.size < 8
#     cid= "0" + cid
#   end
#   f.print c.get_record(cid)
# end
# f.close
