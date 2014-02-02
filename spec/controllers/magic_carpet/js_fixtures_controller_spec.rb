require 'spec_helper'

module MagicCarpet
  describe JsFixturesController do
    describe "fetching a view without variables" do
      it "returns the view's markup" do
        get :index, fixture_controller: "wishes", fixture_action: "plain", use_route: :magic_carpet
        expect(response.body).to eq("<h1>Plain</h1>")
      end
    end
  end
end
