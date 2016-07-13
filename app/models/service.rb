class Service < ActiveRecord::Base

  OTHERS = {
      tp: {
          name: 'Team planner',
          url: 'http://test.teamplanner.nascenia.com/'
      },
      kb: {
          name: 'Knowledge base',
          url: 'http://kb.nascenia.com/'
      },
      fs: {
          name: 'File server',
          url: 'http://192.168.1.2/'
      }
  }
end