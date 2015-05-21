URL_LISTADO = 'http://cartografia.ife.org.mx/sige/servicios/infogeo/pag/get_rango.php'
URL_SECCIONES = 'http://cartografia.ife.org.mx/sige/ajax/get_searchv5'

class String
  def utf_downcase
    self.downcase.tr('ÁÉÍÓÚÜÑ', 'áéíóúüñ')
  end
end

require 'json'
require_relative 'crawler/crawler.rb'