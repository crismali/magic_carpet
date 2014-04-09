require "spec_helper"

module MagicCarpet
  describe JsFixturesController do

    let(:body) { response.body }

    it "renders a template based on the template param" do
      get :index, controller_name: "Wishes", template: "plain", use_route: :magic_carpet
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
          some_array: ["element"],
          some_string: "hello",
          some_model: { model: "Wish", text: "wish text" }
        }
        get :index, locals: locals, controller_name: "Wishes", action_name: "locals", use_route: :magic_carpet
        expect(body).to match("some hash: value")
        expect(body).to match(/some array: \[\&quot;element\&quot;\]/)
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
        get :index, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
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
      get :index, flash: flash, layout: true, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
      controller_flash = controller.send(:controller).flash
      expect(controller_flash["warning"]).to eq(flash[:warning])
      expect(controller_flash["notice"]).to eq(flash[:notice])
    end

    it "sets the session according to session parameter" do
      session_hash = { user_id: "4", wish_id: "9" }
      get :index, session: session_hash, layout: true, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
      controller_session = controller.send(:controller).session
      expect(controller_session["user_id"]).to eq("4")
      expect(controller_session["wish_id"]).to eq("9")
    end

    it "sets the params according to params parameter" do
      params_hash = { user_id: "4", wish_id: "9" }
      get :index, params: params_hash, layout: true, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
      controller_params = controller.send(:controller).params
      expect(controller_params[:user_id]).to eq("4")
      expect(controller_params[:wish_id]).to eq("9")
    end

    describe "error handling" do

      context "logging" do
        it "logs NameErrors" do
          expect(controller.logger).to receive(:error) do |message|
            expect(message).to match("NonExistantController not found.")
            expect(message).to match(/\n\s\s\s\s.*js_fixtures_controller.rb:\d\d:in \`const_get'\n/)
          end
          get :index, controller_name: "NonExistant", action_name: "plain", use_route: :magic_carpet
        end

        it "logs NoMethodErrors" do
          expect(controller.logger).to receive(:error) do |message|
            expect(message).to match("NoMethodError: undefined method `text' for #<User:")
            expect(message).to match(/\n\s\s\s\s.*app\/views\/.*\.html\.erb:2/)
          end
          locals = { wish: { model: "User" } }
          get :index, locals: locals, controller_name: "Wishes", partial: "wish", use_route: :magic_carpet
        end

        it "logs missing template errors" do
          expect(controller.logger).to receive(:error) do |message|
            expect(message).to match("Missing template wishes/fake, application/fake")
            expect(message).to match(/\n\s\s\s\s.*gems\/actionpack/)
          end
          get :index, controller_name: "Wishes", template: "fake", use_route: :magic_carpet
        end
      end

      context "json" do
        it "reports missing/misnamed controllers" do
          get :index, controller_name: "NonExistant", action_name: "plain", use_route: :magic_carpet
          expected = { error: "NonExistantController not found." }.to_json
          expect(body).to eq(expected)
          expect(response.code).to eq("400")
        end

        it "reports missing/misnamed models" do
          locals = { wish: { model: "Dish", text: "wish text" } }
          get :index, locals: locals, controller_name: "Wishes", action_name: "plain", use_route: :magic_carpet
          expected = { error: "Dish not found." }.to_json
          expect(body).to eq(expected)
          expect(response.code).to eq("400")
        end

        it "reports missing template errors" do
          get :index, controller_name: "Wishes", template: "fake", use_route: :magic_carpet
          expect(JSON.parse(body)["error"]).to match("Missing template wishes/fake, application/fake")
          expect(response.code).to eq("400")
        end

        it "reports missing local variable errors" do
          get :index, controller_name: "Wishes", template: "locals", use_route: :magic_carpet
          expected = { error: "undefined local variable or method `some_hash' for 'locals' template." }.to_json
          expect(body).to eq(expected)
          expect(response.code).to eq("400")
        end

        it "reports missing partial errors" do
          get :index, controller_name: "Wishes", partial: "zuh", use_route: :magic_carpet
          expect(JSON.parse(body)["error"]).to match("Missing partial wishes/zuh, application/zuh")
          expect(response.code).to eq("400")
        end

        it "reports no method errors" do
          locals = { wish: { model: "User" } }
          get :index, locals: locals, controller_name: "Wishes", partial: "wish", use_route: :magic_carpet
          error = JSON.parse(body)["error"]
          expect(error).to match("NoMethodError: undefined method `text' for #<User:")
          expect(error).to match(/app\/views\/.*\.html\.erb:2/)
          expect(error).to_not match("activesupport")
          expect(response.code).to eq("400")
        end
      end
    end
  end
end
