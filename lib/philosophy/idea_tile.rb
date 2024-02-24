module Philosophy
  class IdeaTile
    def self.inherited(klass)
      registry[klass.key] = klass
    end

    def self.registry
      @registry ||= {}
    end

    def self.notation(value = nil)
      return @notation if value.nil?
      IdeaTile.registry[value] = self
      @notation = value
    end

    def self.key = name.split('::').last.gsub(/[A-Z]/) { "_#{_1.downcase }" }[1..].to_sym
    def self.to_s = name.split('::').last.gsub(/[A-Z]/) { " #{_1}" }.strip

    VALID_TARGETS = {
      cardinal: %i[ north south east west ],
      diagonal: %i[ ne se nw sw ],
    }

    def self.target(type = nil)
      return @target if type.nil?
      raise ArgumentError unless VALID_TARGETS.key? type
      @target = type
    end

    def self.valid_target?(candidate)
      VALID_TARGETS[target].include? candidate
    end

    def self.target_distance(value = nil)
      if value.nil?
        return 1 if @target_distance.nil?
        return @target_distance 
      end
      raise ArgumentError unless (1..2).include? value
      @target_distance = value
    end

    def self.target_type(kind = nil)
      if kind.nil?
        return :opponent if @target_type.nil?
        return @target_type 
      end
      raise ArgumentError unless %i[ any opponent ].include? kind
      @target_type = kind
    end

    def initialize(owner)
      @owner = owner
      @target = nil
      @moved_this_turn = false
    end
    attr_reader :owner
    attr_accessor :target

    def notation = [ owner, self.class, target ].map(&:notation).join

    protected def lemma(context, &)
      Game::Lemma.new(context, &)
    end

    def return_to_owner!
      key = self.class.registry.invert[self.class]
      @owner.tiles[key] = self
    end

    def reset_state!
      @moved_this_turn = false
    end
  end

  module Tile
    class Push < IdeaTile
      notation :Pu
      target :cardinal

      def lemmas(activation_target, context)
        [lemma(context) { move(activation_target).in_direction_of target }]
      end
    end

    class CornerPush < IdeaTile
      notation :Cp
      target :diagonal

      def lemmas(activation_target, context)
        [lemma(context) { move(activation_target).in_direction_of target }]
      end
    end

    class SlideLeft < IdeaTile
      notation :Sl
      target :cardinal

      def lemmas(activation_target, context)
        leftward =
          case target.value
          when :north then :west
          when :west then :south
          when :south then :east
          when :east then :north
          end
        [lemma(context) { move(activation_target).in_direction_of leftward }]
      end
    end

    class SlideRight < IdeaTile
      notation :Sr
      target :cardinal

      def lemmas(activation_target, context)
        rightward =
          case target.value
          when :north then :east
          when :east then :south
          when :south then :west
          when :west then :north
          end
        [lemma(context) { move(activation_target).in_direction_of rightward }]
      end
    end

    class PullLeft < IdeaTile
      notation :Pl
      target :cardinal

      def lemmas(activation_target, context)
        leftward =
          case target.value
          when :north then :sw
          when :east then :nw
          when :south then :ne
          when :west then :se
          end
        [lemma(context) { move(activation_target).in_direction_of leftward }]
      end
    end

    class PullRight < IdeaTile
      notation :Pr
      target :cardinal

      def lemmas(activation_target, context)
        rightwards =
          case target.value
          when :north then :se
          when :east then :sw
          when :south then :nw
          when :west then :ne
          end
        [lemma(context) { move(activation_target).in_direction_of rightward }]
      end
    end

    class LongShot < IdeaTile
      notation :Ls
      target :cardinal
      target_distance 2

      def lemmas(activation_target, context)
        [lemma(context) { move(activation_target).in_direction_of target }]
      end
    end

    class CornerLongShot < IdeaTile
      notation :Cl
      target :diagonal
      target_distance 2

      def lemmas(activation_target, context)
        [lemma(context) { move(activation_target).in_direction_of target }]
      end
    end

    class Decision < IdeaTile
      notation :De
      target :diagonal

      def lemmas(activation_target, context)
        leftward, rightward =
          case target.value
          when :ne then [:nw, :se]
          when :se then [:ne, :sw]
          when :nw then [:sw, :ne]
          when :sw then [:se, :nw]
          end
        [ lemma(context) { move(activation_target).in_direction_of leftward },
          lemma(context) { move(activation_target).in_direction_of righttward }
        ]
      end
    end

    class Rephrase < IdeaTile
      notation :Re
      target :diagonal
      target_type :any

      def lemmas(activation_target, context)
        %i[ ne se nw sw ].map do |direction|
          lemma(context) { rotate(activation_target).into_direction_of direction }
        end
      end
    end

    class Toss < IdeaTile
      notation :To
      target :cardinal
      
      def lemmas(activation_target, context)
        backwards =
          case target.value
          when :north then :south
          when :south then :north
          when :east then :west
          when :west then :east
          end
        [lemma(context) { move(activation_target).in_direction_of(backwards, 2) }]
      end
    end

    class Persuade < IdeaTile
      notation :Pe
      target :cardinal

      def lemmas(activation_target, context)
        backwards =
          case target.value
          when :north then :south
          when :south then :north
          when :east then :west
          when :west then :east
          end
        [lemma do
          move(activation_target).in_direction_of backwards
          move(origin).in_direction_of backwards
        end]
      end
    end
  end
end

