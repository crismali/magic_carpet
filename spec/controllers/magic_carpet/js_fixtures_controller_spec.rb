require 'spec_helper'

module MagicCarpet
  describe JsFixturesController do

    describe "fetching a view without variables" do
      it "returns the view's markup" do
        get :index, fixture_controller: "wishes", fixture_action: "plain", use_route: :magic_carpet
        expect(response.body).to match("<h1>Plain</h1>\n")
        expect(response.body).to match("<!DOCTYPE html>")
        expect(response.body).to match("<h1>Application Layout</h1>")
      end
    end

    describe "fetching a view with local variables"

    describe "fetching a view with instance variables"

    describe "fetching a view with a specified layout" do

      it "returns the view's markup without the layout" do
        get :index, layout: false, fixture_controller: "wishes", fixture_action: "plain", use_route: :magic_carpet
        expect(response.body).to eq("<h1>Plain</h1>\n")
        expect(response.body).to_not match("<!DOCTYPE html>")
      end

      it "returns the view's markup with the specified layout" do
        get :index, layout: "other_layout", fixture_controller: "wishes", fixture_action: "plain", use_route: :magic_carpet
        expect(response.body).to match("<h1>Other Layout</h1>")
        expect(response.body).to_not match("<h1>Application Layout</h1>")
      end
    end
  end
end
