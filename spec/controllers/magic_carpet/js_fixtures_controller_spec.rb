require 'spec_helper'

module MagicCarpet
  describe JsFixturesController do

    describe "fetching a view without variables" do
      it "returns the view's markup" do
        get :index, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
        expect(response.body).to match("<h1>Plain</h1>\n")
        expect(response.body).to match("<!DOCTYPE html>")
        expect(response.body).to match("<h1>Application Layout</h1>")
      end
    end

    describe "fetching a view with local variables" do

      it "interpretes the objects accurately" do
        locals = {
          some_hash: { key: "value" },
          some_array: [],
          some_string: "hello",
          some_model: { model: "Wish", text: "wish text" }
        }
        get :index, locals: locals, controller_name: "Wishes", action_name: "locals", use_route: :magic_carpet
        expect(response.body).to match("some hash: value")
        expect(response.body).to match(/some array: \[\]/)
        expect(response.body).to match("some string: hello")
        expect(response.body).to match("some model: wish text")
      end
    end

    describe "fetching a view with instance variables" do

      it "sets the specified instance variables" do
        instance_variables = {
          wishes: [
            { id: "1", model: "Wish", text: "first wish" },
            { id: "2", model: "Wish", text: "second wish" },
            { id: "3", model: "Wish", text: "third wish" }
          ]
        }
        get :index, instance_variables: instance_variables, controller_name: "Wishes", action_name: "index", use_route: :magic_carpet

        expect(response.body).to match("first wish")
        expect(response.body).to match("second wish")
        expect(response.body).to match("third wish")
        expect(response.body).to match("/wishes/1")
        expect(response.body).to match("/wishes/2")
        expect(response.body).to match("/wishes/3")
      end
    end

    describe "fetching a view with a specified layout" do

      it "returns the view's markup without the layout" do
        get :index, layout: false, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
        expect(response.body).to eq("<h1>Plain</h1>\n")
        expect(response.body).to_not match("<!DOCTYPE html>")
      end

      it "returns the view's markup with the specified layout" do
        get :index, layout: "other_layout", controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
        expect(response.body).to match("<h1>Other Layout</h1>")
        expect(response.body).to_not match("<h1>Application Layout</h1>")
      end
    end
  end
end
