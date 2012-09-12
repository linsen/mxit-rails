class IndexController < ApplicationController

  include MxitRails::Page

  title 'Templater'

  proceed :welcome, 'Proceed'

end
