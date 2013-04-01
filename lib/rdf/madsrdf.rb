module RDF
  class MADSRDF < RDF::Vocabulary("http://www.loc.gov/mads/rdf/v1#")
    #properties
    property :adminMetadata
    property :affiliationEnd
    property :affiliationStart
    property :authoritativeLabel
    property :citationNote
    property :citationSource
    property :citationStatus
    property :city
    property :classification
    property :code
    property :componentList
    property :country
    property :definitionNote
    property :deletionNote
    property :deprecatedLabel
    property :editorialNote
    property :elementList
    property :elementValue
    property :email
    #TODO: continue alphabetically from here

    #classes
    property :Address
    property :Affiliation
    property :Area
    property :Authority
    property :CitySection
    property :City
    property :ComplexSubject
    #TODO: continue alphabetically from here
    property :Title
  end
end
