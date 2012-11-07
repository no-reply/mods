require 'iso-639'

module Mods

  class Record

    attr_reader :mods_ng_xml
    # string to use when combining a title and subtitle, e.g. 
    #  for title "MODS" and subtitle "Metadata Odious Delimited Stuff" and delimiter " : "
    #  we get "MODS : Metadata Odious Delimited Stuff"
    attr_accessor :title_delimiter

    NS_HASH = {'m' => MODS_NS_V3}
    
    ATTRIBUTES = ['id', 'version']

    # @param (String) what to use when combining a title and subtitle, e.g. 
    #  for title "MODS" and subtitle "Metadata Odious Delimited Stuff" and delimiter " : "
    #  we get "MODS : Metadata Odious Delimited Stuff"
    def initialize(title_delimiter = Mods::TitleInfo::DEFAULT_TITLE_DELIM)
      @title_delimiter = title_delimiter
    end

    # convenience method to call Mods::Reader.new.from_str and to nom
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is false
    # @param str - a string containing mods xml
    def from_str(str, ns_aware = false)
      @mods_ng_xml = Mods::Reader.new(ns_aware).from_str(str)
      if ns_aware
        set_terminology_ns(@mods_ng_xml)
      else
        set_terminology_no_ns(@mods_ng_xml)
      end
    end

    # convenience method to call Mods::Reader.new.from_url and to nom
    # @param ns_aware true if the XML parsing should be strict about using namespaces.  Default is false
    # @param url (String) - url that has mods xml as its content
    def from_url(url, namespace_aware = false)
      @mods_ng_xml = Mods::Reader.new(ns_aware).from_url(url)
      if ns_aware
        set_terminology_ns(@mods_ng_xml)
      else
        set_terminology_no_ns(@mods_ng_xml)
      end
    end

    # @return Array of Strings, each containing the text contents of <mods><titleInfo>   <nonSort> + ' ' + <title> elements
    #  but not including any titleInfo elements with type="alternative"
    def short_titles
      @mods_ng_xml.title_info.short_title.map { |n| n }
    end

    # @return Array of Strings, each containing the text contents of <mods><titleInfo>   <nonSort> + ' ' + <title> + (delim) + <subTitle> elements
    def full_titles
      @mods_ng_xml.title_info.full_title.map { |n| n }
    end
        
    # @return Array of Strings, each containing the text contents of <mods><titleInfo @type="alternative"><title>  elements
    def alternative_titles
      @mods_ng_xml.title_info.alternative_title.map { |n| n }
    end
    
    # @return String containing sortable title for this mods record
    def sort_title
      @mods_ng_xml.title_info.sort_title.find { |n| !n.nil? }
    end
    
    
    # use the displayForm of a personal name if present
    #   if no displayForm, try to make a string from family name and given name "family_name, given_name"
    #   otherwise, return all nameParts concatenated together
    # @return Array of Strings, each containing the above described string
    def personal_names
      @mods_ng_xml.personal_name.map { |n|
        if n.displayForm.size > 0
          n.displayForm.text
        elsif n.family_name.size > 0
          n.given_name.size > 0 ? n.family_name.text + ', ' + n.given_name.text : n.family_name.text
        else
          n.namePart.text
        end
      }
    end

    # use the displayForm of a corporate name if present
    #   otherwise, return all nameParts concatenated together
    # @return Array of Strings, each containing the above described string
    def corporate_names
      @mods_ng_xml.corporate_name.map { |n|
        if n.displayForm.size > 0
          n.displayForm.text
        else
          n.namePart.text 
        end
      }
    end
    
    # Translates iso-639 language codes, and leaves everything else alone.
    # @return Array of Strings, each a (hopefully English) name of a language
    def languages
      result = []
      @mods_ng_xml.language.each { |n| 
        # get languageTerm codes and add their translations to the result
        n.code_term.each { |ct| 
          if ct.authority.first.match(/^iso639/)
            begin
              vals = ct.text.split(/[,|\ ]/).reject {|x| x.strip.length == 0 } 
              vals.each do |v|
                result << ISO_639.find(v.strip).english_name
              end
            rescue => e
              p "Couldn't find english name for #{code.text}"
              result << ct.text
            end
          else
            result << ct.text
          end
        }
        # add languageTerm text values
        n.text_term.each { |tt| 
          val = tt.text.strip
          result << val if val.length > 0
        }
          
        # add language values that aren't in languageTerm subelement
        if n.languageTerm.size == 0
          result << n.text
        end
      }
      result.uniq
    end


    def method_missing method_name, *args
      if mods_ng_xml.respond_to?(method_name)
        mods_ng_xml.send(method_name, *args)
      else
        super.method_missing(method_name, *args)
      end
    end
    
  end # class Record

end # module Mods