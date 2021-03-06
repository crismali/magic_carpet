require "spec_helper"
require "ostruct"

module MagicCarpet
  describe JsFixturesHelper do
    describe "#hydrate" do
      context "hashes" do
        it "doesn't change the true values" do
          original = { truncate: true }.with_indifferent_access
          actual = helper.hydrate(original)
          expect(actual[:truncate]).to be_true
        end

        it "doesn't change the false values" do
          original = { truncate: false }.with_indifferent_access
          actual = helper.hydrate(original)
          expect(actual[:truncate]).to be_false
        end

        it "doesn't change the nil values" do
          original = { truncate: nil }.with_indifferent_access
          actual = helper.hydrate(original)
          expect(actual[:truncate]).to be_nil
        end

        it "converts model hashes to models" do
          hash = {
            user: {
              model: "User",
              username: "username"
            }.with_indifferent_access
          }.with_indifferent_access
          actual = helper.hydrate(hash)
          expect(actual[:user].username).to eq("username")
        end

        it "converts numbers" do
          hash = { some_number: { number: "1.2" } }
          actual = helper.hydrate(hash)
          expect(actual[:some_number]).to eq(1.2)
        end

        it "processes all values in an array" do
          expected = [1, 2, 3].map { |num| "wish text #{num}" }
          hash = {
            wishes: [
              { model: "Wish", text: expected.first }.with_indifferent_access,
              { model: "Wish", text: expected.second }.with_indifferent_access,
              { model: "Wish", text: expected.last }.with_indifferent_access
            ]
          }.with_indifferent_access
          wishes = helper.hydrate(hash)[:wishes].map(&:text)
          expect(wishes).to eq(expected)
        end

        it "processes all values in a nested hash" do
          hash = {
            numbers: [{ number: "5" }.with_indifferent_access],
            named_wishes: {
              favorite_wish: { model: "Wish", text: "fave" }.with_indifferent_access,
              other_wishes: [
                { model: "Wish", text: "not fave" }.with_indifferent_access,
                { model: "Wish", text: "something silly" }.with_indifferent_access
              ]
            }.with_indifferent_access
          }.with_indifferent_access

          actual = helper.hydrate(hash)
          named_wishes = actual[:named_wishes]
          expect(actual[:numbers]).to eq([5])
          expect(named_wishes[:favorite_wish].text).to eq("fave")
          expect(named_wishes[:other_wishes].map(&:text)).to eq(["not fave", "something silly"])
        end
      end

      context "'numbers'" do
        it "returns a float by default" do
          hash = { number: "1.5" }.with_indifferent_access
          actual = helper.hydrate(hash)
          expect(actual).to eq(1.5)
          expect(actual.class).to eq(Float)
        end

        it "returns an integer when 'integer' is set to true" do
          hash = { number: "1.5", integer: true }.with_indifferent_access
          actual = helper.hydrate(hash)
          expect(actual).to eq(1)
          expect(actual).to be_kind_of(Integer)
        end
      end

      context "dates and times" do
        let(:now) { Time.now }

        context "'dates'" do
          it "returns a date" do
            hash = { date: now.to_s }.with_indifferent_access
            actual = helper.hydrate(hash)
            expect(actual).to eq(Date.today)
          end
        end

        context "'times'" do
          it "returns a time" do
            hash = { time: now.to_s }.with_indifferent_access
            actual = helper.hydrate(hash)
            expect(actual.to_i).to eq(now.to_i)
          end

          it "returns a utc time when specified" do
            hash = { time: now.to_s, utc: "true" }.with_indifferent_access
            actual = helper.hydrate(hash)
            expect(actual).to be_utc
          end
        end

        context "'date times'" do
          it "returns a date time" do
            hash = { datetime: now.to_s }.with_indifferent_access
            actual = helper.hydrate(hash)
            expect(actual.class).to eq(DateTime)
            expect(actual.to_time.to_i).to eq(now.to_time.to_i)
          end
        end
      end

      context "nil" do
        it "converts a string of 'nil' to nil" do
          expect(helper.hydrate("nil")).to be_nil
        end
      end

      context "false" do
        it "converts a string of 'false' to false" do
          expect(helper.hydrate("false")).to eq(false)
        end
      end

      context "true" do
        it "converts a string of 'true' to true" do
          expect(helper.hydrate("true")).to eq(true)
        end
      end

      context "'models'" do
        it "converts the hash into the model specified by 'model'" do
          hash = { model: "Wish", text: "wish text" }.with_indifferent_access
          actual = helper.hydrate(hash)
          expect(actual.attributes).to eq(Wish.new(text: "wish text").attributes)
        end

        it "converts nested associations into specified models" do
          hash = {
            model: "Wish",
            text: "wish text",
            user: {
              username: "username",
              model: "User"
            }
          }
          wish = helper.hydrate(hash)
          expect(wish.text).to eq("wish text")
          expect(wish.user.username).to eq("username")
        end

        it "converts nested numbers" do
          hash = {
            model: "Wish",
            id: "5",
            text: "wish text",
            user: {
              username: "username",
              model: "User",
              id: "1"
            }
          }
          wish = helper.hydrate(hash)
          expect(wish.id).to eq(5)
          expect(wish.user.id).to eq(1)
        end

        it "converts nested hashes and arrays" do
          hash = {
            model: "OpenStruct",
            text: "ostruct",
            array: [{ number: "5" }.with_indifferent_access],
            my_hash: {
              wish: { model: "Wish", text: "wish text" }
            }
          }
          actual = helper.hydrate(hash)
          expect(actual.text).to eq("ostruct")
          expect(actual.array).to eq([5])
          expect(actual.my_hash[:wish].text).to eq("wish text")
        end
      end

      context "arrays" do
        it "converts each element of the array" do
          array = [
            "hello",
            { number: "5" }.with_indifferent_access,
            { model: "Wish", text: "wish text" }.with_indifferent_access
          ]
          string, number, wish = helper.hydrate(array)
          expect(string).to eq("hello")
          expect(number).to eq(5)
          expect(wish.text).to eq("wish text")
        end

        it "converts nested arrays" do
          array = [
            [{ model: "Wish", text: "wish text" }.with_indifferent_access],
            { number: "5" }.with_indifferent_access
          ]
          sub_array, number = helper.hydrate(array)
          expect(sub_array.first.text).to eq("wish text")
          expect(number).to eq(5)
        end

        it "converts hashes the array contains" do
          array = [
            {
              my_wish: { model: "Wish", text: "my wish" }.with_indifferent_access,
              my_number: { number: "5" }
            }.with_indifferent_access
          ]
          actual = helper.hydrate(array).first
          expect(actual[:my_wish].text).to eq("my wish")
          expect(actual[:my_number]).to eq(5)
        end
      end

      context "'arrays'" do
        it "converts each element of the 'array'" do
          pretend_array = {
            "0" => "hello",
            "1" => { number: "5" }.with_indifferent_access,
            "2" => { model: "Wish", text: "wish text" }.with_indifferent_access
          }
          string, number, wish = helper.hydrate(pretend_array)
          expect(string).to eq("hello")
          expect(number).to eq(5)
          expect(wish.text).to eq("wish text")
        end
      end
    end
  end
end
