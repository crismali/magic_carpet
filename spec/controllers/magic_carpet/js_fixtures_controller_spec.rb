require 'spec_helper'

module MagicCarpet
  describe JsFixturesController do

    describe "fetching a view without variables" do
      it "returns the view's markup" do
        get :index, fixture_controller: "wishes", fixture_action: "plain", use_route: :magic_carpet
        expect(response.body).to match("<h1>Plain</h1>\n")
        expect(response.body).to match("<!DOCTYPE html>")
        expect(response.body).to match("<head>")
      end

      it "returns the view's markup without the layout" do
        get :index, layout: false, fixture_controller: "wishes", fixture_action: "plain", use_route: :magic_carpet
        expect(response.body).to match("<h1>Plain</h1>\n")
        expect(response.body).to_not match("<!DOCTYPE html>")
        expect(response.body).to_not match("<head>")
      end
    end
  end
end
