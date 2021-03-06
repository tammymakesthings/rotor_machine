############################################################################
# rotor_machine: Simple ruby implemenation of an Enigma rotor @machine.
#
# File        : rotor_factory_spec.rb
# Specs for   : The rotor factory, which provides a simplified interface for
#               creating rotors and reflectors.
############################################################################
#  Copyright 2018, Tammy Cravit.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
############################################################################

require 'rspec'
require 'spec_helper'
require 'rotor_machine'

require_custom_matcher_named "rotor_state"
require_custom_matcher_named "reflector_state"

RSpec.describe "RotorMachine::Factory" do
  context "the preliminaries" do
    it "should provide factory method for building Enigma components" do
      expect(RotorMachine::Factory).to respond_to(:build_rotor)
      expect(RotorMachine::Factory).to respond_to(:build_reflector)
      expect(RotorMachine::Factory).to respond_to(:build_plugboard)
      expect(RotorMachine::Factory).to respond_to(:build_machine)
      expect(RotorMachine::Factory).to respond_to(:default_machine)
      expect(RotorMachine::Factory).to respond_to(:empty_machine)
    end
  end

  context "#default_machine" do
    it "should provide a default machine via the #default_machine factory method" do
      machine = RotorMachine::Factory.default_machine

      expect(machine.rotors).to be_a(Array)
      expect(machine.rotors.length).to be == 3
      machine.rotors.each { |r| expect(r).to be_a(RotorMachine::Rotor) }
      expect(machine.rotors[0]).to have_rotor_state(kind: :ROTOR_I, letter: "A", step_size: 1)
      expect(machine.rotors[1]).to have_rotor_state(kind: :ROTOR_II, letter: "A", step_size: 1)
      expect(machine.rotors[2]).to have_rotor_state(kind: :ROTOR_III, letter: "A", step_size: 1)

      expect(machine.reflector).to be_a(RotorMachine::Reflector)
      expect(machine.reflector).to have_reflector_state(kind: :REFLECTOR_A,
                                                        position: 0,
                                                        letter: RotorMachine::Reflector::REFLECTOR_A[0])

      expect(machine.plugboard).not_to be_nil
      expect(machine.plugboard).to be_a(RotorMachine::Plugboard)
    end
  end

  context "#empty_machine" do
    it "should provide a machine with no rotors or reflector via the #empty_machine factory method" do
      machine = RotorMachine::Factory.empty_machine
      expect(machine.rotors).to be_a(Array)
      expect(machine.rotors.length).to be == 0
      expect(machine.reflector).to be_nil
      expect(machine.plugboard).not_to be_nil
      expect(machine.plugboard).to be_a(RotorMachine::Plugboard)
    end
  end

  context "#build_reflector" do
    context "specifying reflector alphabet" do
      it "should allow specifying of a reflector constant name" do
        expect {@r = RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A)}.not_to raise_exception
        expect(@r).to have_reflector_state(kind: :REFLECTOR_A, position: 0)
      end

      it "should allow specifying of a reflector alphabet" do
        expect {@r = RotorMachine::Factory.build_reflector(reflector_kind: "QWERTYUIOPASDFGHJKLZXCVBNM")}.not_to raise_exception
        expect(@r).to have_reflector_state(kind: "QWERTYUIOPASDFGHJKLZXCVBNM", position: 0)
        expect(@r).to have_reflector_state(kind: :CUSTOM)
      end

      it "should raise an error if the reflector constant name is not specified" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: nil)}.to raise_exception(ArgumentError)
      end

      it "should raise an error if the reflector constant name is not defined" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :UNDEFINED_ROTOR)}.to raise_exception(ArgumentError)
      end

      it "should raise an error if the reflector alphabet is the wrong length" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: "TOO SHORT")}.to raise_exception(ArgumentError)
        expect {RotorMachine::Factory.build_reflector(reflector_kind: "QWERTYUIOPASDFGHJKLZXCVBNMEXTRALETTERS")}.to raise_exception(ArgumentError)
      end

      it "should raise an error if an invalid type is provided for reflector_kind" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: false)}.to raise_exception(ArgumentError)
      end
    end

    context "specifying initial position" do
      it "should allow specifying the initial position as a character" do
        expect {@r = RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A, initial_position: "A")}.not_to raise_exception
        expect(@r).to have_reflector_state(kind: :REFLECTOR_A, letter: "A", position: RotorMachine::Reflector::REFLECTOR_A.index("A"))
      end

      it "should allow specifying the initial position as a number" do
        expect {@r = RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A, initial_position: 7)}.not_to raise_exception
        expect(@r).to have_reflector_state(kind: :REFLECTOR_A, position: 7, letter: RotorMachine::Reflector::REFLECTOR_A[7])
      end

      it "shoudl raise an error if the position letter is not present on the rotor" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A, initial_position: "*")}.to raise_error(ArgumentError)
      end

      it "should raise an error if the numeric position is out of range" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A,
                                                  initial_position: -1)}.to raise_error(ArgumentError)
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A,
                                                  initial_position: 38)}.to raise_error(ArgumentError)
      end

      it "should raise an error if the initial position is of invalid type" do
        expect {RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A,
                                                  initial_position: false)}.to raise_error(ArgumentError)
      end
    end
  end

  context "#build_rotor" do
    context "specifying rotor alphabet" do
      it "should allow specifying of a rotor constant name" do
        expect {@r = RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I)}.not_to raise_exception
        expect(@r).to have_rotor_state(kind: :ROTOR_I)
      end

      it "should allow specifying of a rotor alphabet" do
        expect {@r = RotorMachine::Factory.build_rotor(rotor_kind: "QWERTYUIOPASDFGHJKLZXCVBNM")}.not_to raise_exception
        expect(@r).to have_rotor_state(kind: :CUSTOM)
        expect(@r).to have_rotor_state(kind: "QWERTYUIOPASDFGHJKLZXCVBNM")
      end

      it "should raise an error if the rotor constant name is not defined" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :UNDEFINED_ROTOR)}.to raise_exception(ArgumentError)
      end

      it "should raise an error if the rotor alphabet is the wrong length" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: "TOO SHORT")}.to raise_exception(ArgumentError)
        expect {RotorMachine::Factory.build_rotor(rotor_kind: "QWERTYUIOPASDFGHJKLZXCVBNMEXTRALETTERS")}.to raise_exception(ArgumentError)
      end

      it "should raise an error if an invalid type is provided for rotor alphabet" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: false)}.to raise_exception(ArgumentError)
      end

      it "should raise an error if a nil value is provided for rotor alphabet" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: nil)}.to raise_exception(ArgumentError)
      end
    end

    context "specifying initial position" do
      it "should allow specifying the initial position as a character" do
        expect {@r = RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: "A")}.not_to raise_exception
        expect(@r).to have_rotor_state(kind: :ROTOR_I,
                                       letter: "A",
                                       position: RotorMachine::Rotor::ROTOR_I.index("A"))
      end

      it "should allow specifying the initial position as a number" do
        expect {@r = RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: 7)}.not_to raise_exception
        expect(@r).to have_rotor_state(kind: :ROTOR_I,
                                       letter: RotorMachine::Rotor::ROTOR_I[7],
                                       position: 7)
      end

      it "should raise an error if the position letter is not present on the rotor" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: "*")}.to raise_error(ArgumentError)
      end

      it "should raise an error if the numeric position is out of range" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I,
                                                  initial_position: -1)}.to raise_error(ArgumentError)
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I,
                                                  initial_position: 38)}.to raise_error(ArgumentError)
      end

      it "should raise an error if the position is of an invalid type" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I,
                                                  initial_position: false)}.to raise_error(ArgumentError)
      end

      it "should raise an error if the step_size is of an invalid type" do
        expect {RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I,
                                                  initial_position: 10,
                                                  step_size: false)}.to raise_error(ArgumentError)
      end
    end

    context "#build_plugboard" do
      it "should create a plugboard object" do
        pb = RotorMachine::Factory.build_plugboard()
        expect(pb).to be_instance_of(RotorMachine::Plugboard)
      end
    end

    context "#build_machine" do
      before(:each) do
        @rs = [
          RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_I, initial_position: 0),
          RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_II, initial_position: 0),
          RotorMachine::Factory.build_rotor(rotor_kind: :ROTOR_III, initial_position: 0)
        ]
        @rf = RotorMachine::Factory.build_reflector(reflector_kind: :REFLECTOR_A)
        @cn = {"A" => "Q", "R" => "Y"}
        @m = nil
      end

      after(:each) do
        @rs = nil
        @rf = nil
        @cn = nil
        @m = nil
      end

      it "should allow you to construct a machine with rotors and a reflector" do
        expect { @m = RotorMachine::Factory.build_machine(rotors: @rs, reflector: @rf) }.not_to raise_error

        expect(@m).to be_instance_of(RotorMachine::Machine)
        expect(@m.rotors.count).to be == 3
        expect(@m.rotors[0]).to have_rotor_state(kind: :ROTOR_I, position: 0)
        expect(@m.rotors[1]).to have_rotor_state(kind: :ROTOR_II, position: 0)
        expect(@m.rotors[2]).to have_rotor_state(kind: :ROTOR_III, position: 0)
        expect(@m.reflector).to be_instance_of(RotorMachine::Reflector)
        expect(@m.plugboard).to be_instance_of(RotorMachine::Plugboard)

        expect(@m.reflector.reflector_kind_name).to be == :REFLECTOR_A
      end

      it "should allow you to construct a machine with an empty rotor set" do
        expect {@m = RotorMachine::Factory.build_machine(reflector: @rf)}.not_to raise_error
        expect(@m.rotors.count).to be == 0
      end

      it "should allow you to construct a machine with no reflector loaded" do
        expect {@m = RotorMachine::Factory.build_machine(rotors: @rs)}.not_to raise_error
        expect(@m.reflector).to be_nil
      end

      it "should raise an exception if an invalid rotor object is supplied" do
        @rs[0] = false
        expect {@m = RotorMachine::Factory.build_machine(rotors: @rs)}.to raise_error(ArgumentError)
      end

      it "should raise an exception if an invalid reflector object is supplied" do
        expect {@m = RotorMachine::Factory.build_machine(rotors: @rs, reflector: false)}.to raise_error(ArgumentError)
      end

      it "should allow you to construct a machine with plugboard connections specified" do
        expect {@m = RotorMachine::Factory.build_machine(rotors: @rs, reflector: @rf, connections: @cn)}.not_to raise_error
        "AQRY".chars.each { |l| expect(@m.plugboard.connected?(l)).to be_truthy }
      end

      it "should allow you to specify rotors and reflectors as symbols" do
        expect {@m = RotorMachine::Factory.build_machine(
          rotors: [:ROTOR_I, :ROTOR_II, :ROTOR_III],
          reflector: :REFLECTOR_A,
          connections: @cn)}.not_to raise_error

        expect(@m).to be_instance_of(RotorMachine::Machine)
        expect(@m.rotors.count).to be == 3
        expect(@m.rotors[0]).to have_rotor_state(kind: :ROTOR_I,
                                                 position: 0,
                                                 letter: RotorMachine::Rotor::ROTOR_I[0],
                                                 step_size: 1)
        expect(@m.rotors[1]).to have_rotor_state(kind: :ROTOR_II,
                                                 position: 0,
                                                 letter: RotorMachine::Rotor::ROTOR_II[0],
                                                 step_size: 1)
        expect(@m.rotors[2]).to have_rotor_state(kind: :ROTOR_III,
                                                 position: 0,
                                                 letter: RotorMachine::Rotor::ROTOR_III[0],
                                                 step_size: 1)
        expect(@m.reflector).to be_instance_of(RotorMachine::Reflector)
        expect(@m.plugboard).to be_instance_of(RotorMachine::Plugboard)

        expect(@m.reflector.reflector_kind_name).to be == :REFLECTOR_A
      end

      it "should define make_* aliases for the build_* methods" do
        ["rotor", "reflector", "plugboard", "machine"].each do |mn|
          expect(RotorMachine::Factory).to respond_to("make_#{mn}".to_sym)
          expect(RotorMachine::Factory.method("make_#{mn}".to_sym).original_name.to_s).to be == "build_#{mn}"
        end
      end
    end
  end
end
