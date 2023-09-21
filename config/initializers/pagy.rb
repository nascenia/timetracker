Pagy::DEFAULT[:items] = 50        # items per page
Pagy::DEFAULT[:size]  = [1,4,4,1] # nav bar links

require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page
