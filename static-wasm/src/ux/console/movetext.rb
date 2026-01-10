module Ux
  module Console
    module Movetext
      def self.input = document.querySelector('#movetext input')[:value].to_s
      def self.error = document.querySelector('#movetext #error')

      def self.submit
        begin
          current_game << input
          Ux.render
        rescue Philosophy::Game::Event::Unrecognized
          error[:innerHTML] = "Syntax incorrect. No idea what you meant."
        rescue Philosophy::Game::Placement::InvalidFirstMove
          error[:innerHTML] = "You may not play C5 first."
        rescue Philosophy::Game::Placement::LocationOutsidePlacementSpace
          error[:innerHTML] = "You must play within the central 9 spaces."
        rescue Philosophy::Game::Placement::InvalidTileType
          error[:innerHTML] = "Unrecognized tile type selected."
        rescue Philosophy::Game::Placement::UnavailableTile
          error[:innerHTML] = "You've already played that tile."
        rescue Philosophy::Game::Placement::InvalidLocation
          error[:innerHTML] = "This location does not exist."
        rescue Philosophy::Game::Placement::CannotPlaceAtopExistingTile
          error[:innerHTML] = "A tile is already in this space. Cannot place."
        rescue Philosophy::Game::Placement::CannotOrientInTargetDirection
          error[:innerHTML] = "This tile cannot be oriented in that direction."
        rescue Philosophy::Game::Placement::IncorrectPlayer
          error[:innerHTML] = "It is not this player's turn."
        rescue Philosophy::Game::Choice::Error
          error[:innerHTML] = "Not a valid choice."
        end
      end

      def self.build
        wrapper = Ux.build_element element: :div, id: :movetext

        label = Ux.build_element element: :span, innerHTML: 'Movetext:'
        input = Ux.build_element element: :input, type: :text
        button = Ux.build_element element: :button, innerHTML: 'Submit'
        errors = Ux.build_element element: :div, id: :error

        input.addEventListener('keypress') do |event|
          case event[:key].to_s
          when 'Enter' then submit
          end
        end
        button.addEventListener('click') { submit }

        wrapper.appendChild label
        wrapper.appendChild input
        wrapper.appendChild button
        wrapper.appendChild errors

        wrapper
      end
    end
  end
end
