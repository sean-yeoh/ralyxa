module Ralyxa
  module ResponseEntities
    module Directives
      class AlexaPresentationLanguage
        class << self

          def render(datasources: nil, document:, speech: nil, session_attributes: nil, response_builder: Ralyxa::ResponseBuilder)
            directive = build_directive(document, datasources)
            json = response_builder.build(build_options(directive, speech))
            response = JSON.parse(json)

            response[:sessionAttributes] = session_attributes if session_attributes
            response.to_json
          end

          private

          def build_options(directive, speech)
            {}.tap do |option|
              option[:directives] = [directive]
              option[:end_session] = false
              option[:response_text] = speech if speech
            end
          end

          def build_directive(document, datasources)
            {
              type: "Alexa.Presentation.APL.RenderDocument",
              document: {
                src: "doc://alexa/apl/documents/#{document}",
                type: "Link"
              },
              datasources: datasources
            }
          end
        end
      end
    end
  end
end
