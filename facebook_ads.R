devtools::install_github("facebookresearch/Radlibrary")

library(Radlibrary)
token <- "EAAmcFZC9dSA4BACUs2ltNqzaxq5N2tV3p0og4ZCSQMyZBzXZCpqxSBZCXAPLoiB5aQHTVZBqjzYYuSicr8vSrsFyu5ng4DlCYMSyDLXTiUoZBa35ymlY6uAZB3hfZCZBZBOiWR42LM4cDOCg3Pew2ZBg7J44Jjv6cj1W0Qr0K5ulJ2TA5XklzBVgGFZB7QP0TGbo2PAmPFRinZCrxONc2FMcTYixE2mmT57OEVOf0ZAYPHxE9LmZCAZDZD"

query <- adlib_build_query(ad_reached_countries = 'US', 
                           ad_active_status = 'ACTIVE', 
                           impression_condition = 'HAS_IMPRESSIONS_LAST_90_DAYS', 
                           search_terms = "healthcare",
                           fields = "ad_data")
response <- adlib_get(params = query, token = token)

