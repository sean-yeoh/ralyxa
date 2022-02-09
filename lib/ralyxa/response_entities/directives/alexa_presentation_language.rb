module Ralyxa
  module ResponseEntities
    module Directives
      class AlexaPresentationLanguage
        class << self

          def render(datasources: nil, document:, idle_minutes: 10, speech: nil, session_attributes: nil, response_builder: Ralyxa::ResponseBuilder)
            directive = build_directive(document, datasources)
            options_hash = build_options(
              directive: directive,
              speech: speech,
              document: document,
              idle_delay: idle_minutes * 60000 # milliseconds
            )

            json = response_builder.build(options_hash)
            response = JSON.parse(json)

            response[:sessionAttributes] = session_attributes if session_attributes
            response.to_json
          end

          private

          def build_options(directive:, document:, idle_delay:, speech:)
            idle_directive = {
              type: 'Alexa.Presentation.APL.ExecuteCommands',
              token: document,
              commands: [
                {
                  type: "Idle",
                  delay: idle_delay
                }
              ]
            }

            {}.tap do |option|
              option[:directives] = [directive, idle_directive]
              option[:end_session] = false
              option[:response_text] = speech if speech
            end
          end

          def build_directive(document, datasources)
            {
              type: "Alexa.Presentation.APL.RenderDocument",
              token: document,
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
