require 'spec_helper'

module MagicCarpet
  describe JsFixturesController do

    describe "fetching a view without variables" do
      it "returns the view's markup" do
        get :index, controller_name: "wishes", action_name: "plain", use_route: :magic_carpet
        expect(response.body).to match("<h1>Plain</h1>\n")
        expect(response.body).to match("<!DOCTYPE html>")
        expect(response.body).to match("<h1>Application Layout</h1>")
      end
    end

    describe "fetching a view with local variables" do

      it "interpretes the objects literally" do
        locals = {
          some_hash: { key: "value" },
          some_array: [1,2,3],
          some_number: 1,
          some_string: "hello"
        }
        get :index, locals: locals, controller_name: "wishes", action_name: "locals", use_route: :magic_carpet
        expect(response.body).to match("some hash: value")
        expect(response.body).to match("some array: 2")
        expect(response.body).to match("some number: 1")
        expect(response.body).to match("some string: hello")
      end
    end

    describe "fetching a view with instance variables"

    describe "fetching a view with a specified layout" do

      it "returns the view's markup without the layout" do
        get :index, layout: false, controller_name: "wishes", action_name: "plain", use_route: :magic_carpet
        expect(response.body).to eq("<h1>Plain</h1>\n")
        expect(response.body).to_not match("<!DOCTYPE html>")
      end

      it "returns the view's markup with the specified layout" do
        get :index, layout: "other_layout", controller_name: "wishes", action_name: "plain", use_route: :magic_carpet
        expect(response.body).to match("<h1>Other Layout</h1>")
        expect(response.body).to_not match("<h1>Application Layout</h1>")
      end
    end
  end
end
