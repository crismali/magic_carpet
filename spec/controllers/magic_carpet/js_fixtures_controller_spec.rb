require "spec_helper"

module MagicCarpet
  describe JsFixturesController do

    let(:body) { response.body }

    it "renders a template based on the template param" do
      get :index, controller_name: "Wishes", action_name: "locals", template: "plain", use_route: :magic_carpet
      expect(body).to match("<h1>Plain</h1>\n")
    end

    it "renders based on controller and action names if there's no template param" do
      get :index, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
      expect(body).to match("<h1>Plain</h1>\n")
    end

    describe "fetching a view without variables" do
      it "returns the view's markup" do
        get :index, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
        expect(body).to match("<h1>Plain</h1>\n")
        expect(body).to match("<!DOCTYPE html>")
        expect(body).to match("<h1>Application Layout</h1>")
      end
    end

    describe "rendering a partial" do

      it "is done by passing the partial's path in the partial option" do
        hash = {
          wish: { model: "Wish" }
        }
        get :index, partial: "form", controller_name: "Wishes", use_route: :magic_carpet, instance_variables: hash
        expect(body).to match("<form")
        expect(body).to match("Create Wish")
      end

      it "passes collection through when passed" do
        collection = [
          { model: "Wish", text: "wish text 1", id: 1 },
          { model: "Wish", text: "wish text 2", id: 2 },
          { model: "Wish", text: "wish text 3", id: 3 }
        ]
        get :index, partial: "wish", collection: collection, controller_name: "Wishes", use_route: :magic_carpet
        expect(body).to match("wish text 1")
        expect(body).to match("wish text 2")
        expect(body).to match("wish text 3")
      end

      it "accepts the 'as' option" do
        collection = [
          { model: "OpenStruct", id: 1 },
          { model: "User", id: 2 },
          { model: "Wish", id: 3 }
        ]
        get :index, partial: "shared/id_able", collection: collection, as: "id_able", controller_name: "Wishes", use_route: :magic_carpet
        expect(body).to match(/id: 1\n\s+class: OpenStruct/)
        expect(body).to match(/id: 2\n\s+class: User/)
        expect(body).to match(/id: 3\n\s+class: Wish/)
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
        expect(body).to match("some hash: value")
        expect(body).to match(/some array: \[\]/)
        expect(body).to match("some string: hello")
        expect(body).to match("some model: wish text")
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

        expect(body).to match("first wish")
        expect(body).to match("second wish")
        expect(body).to match("third wish")
        expect(body).to match("/wishes/1")
        expect(body).to match("/wishes/2")
        expect(body).to match("/wishes/3")
      end
    end

    describe "fetching a view with a specified layout" do

      it "returns the view's markup without the layout" do
        get :index, layout: false, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
        expect(body).to eq("<h1>Plain</h1>\n")
        expect(body).to_not match("<!DOCTYPE html>")
      end

      it "returns the view's markup with the specified layout" do
        get :index, layout: "other_layout", controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
        expect(body).to match("<h1>Other Layout</h1>")
        expect(body).to_not match("<h1>Application Layout</h1>")
      end
    end

    it "sets flash messages according to flash parameter" do
      flash = {
        warning: "this is a flash message",
        notice: "something noteworthy"
      }
      get :index, flash: flash, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
      expect(body).to match("warning: #{flash[:warning]}")
      expect(body).to match("notice: #{flash[:notice]}")
    end

  end
end
