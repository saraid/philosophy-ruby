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
      VALID_TARGETS[target].include? Board::Direction[candidate].value
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
    def with(target:) = dup.tap { _1.target = target }
    def activation_target(spaces, from_location)
      spaces[spaces[from_location].coordinate.translate(target, self.class.target_distance)]
    end
  end

  module Tile
    class Push < IdeaTile
      notation :Pu
      target :cardinal
    end

    class CornerPush < IdeaTile
      notation :Cp
      target :diagonal
    end

    class SlideLeft < IdeaTile
      notation :Sl
      target :cardinal
    end

    class SlideRight < IdeaTile
      notation :Sr
      target :cardinal
    end

    class PullLeft < IdeaTile
      notation :Pl
      target :cardinal
    end

    class PullRight < IdeaTile
      notation :Pr
      target :cardinal
    end

    class LongShot < IdeaTile
      notation :Ls
      target :cardinal
      target_distance 2
    end

    class CornerLongShot < IdeaTile
      notation :Cl
      target :diagonal
      target_distance 2
    end

    class Decision < IdeaTile
      notation :De
      target :diagonal
    end

    class Rephrase < IdeaTile
      notation :Re
      target :diagonal
      target_type :any
    end

    class Toss < IdeaTile
      notation :To
      target :cardinal
    end

    class Persuade < IdeaTile
      notation :Pe
      target :cardinal
    end
  end
end

