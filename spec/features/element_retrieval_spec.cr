require "../spec_helper"

module Selenium::Command
  describe "element retrieval", tags: "feature" do
    it "can retrieve a single element" do
      TestServer.route "/home", <<-HTML
      <ul>
        <li data-testid="item-0">
          <p id="words">First Item</p>
        </li>
        <li data-testid="item-1">
          <p id="words">Second Item</p>
        </li>
      </ul>
      HTML

      driver = Driver.new
      http_client = driver.http_client

      with_session(driver) do |session|
        session_id = session.id
        NavigateTo.new(http_client, session_id).execute("localhost:3002/home")
        element_id = FindElement.new(http_client, session_id).execute(using: LocationStrategy::CSS, value: "[data-testid=\"item-1\"]")
        child_element_id = FindElementFromElement.new(http_client, session_id, element_id).execute(using: LocationStrategy::CSS, value: "#words")
        element_text = GetElementText.new(http_client, session_id).execute(element_id)

        element_text.should eq("Second Item")
      end
    end

    it "can retrieve multiple elements" do
      TestServer.route "/home", <<-HTML
      <ul>
        <li data-testid="item-0">
          <p id="words">First Item</p>
          <p>Sub Text</p>
        </li>
        <li data-testid="item-1">
          <p id="words">Second Item</p>
        </li>
      </ul>
      HTML

      driver = Driver.new
      http_client = driver.http_client

      with_session(driver) do |session|
        session_id = session.id
        NavigateTo.new(http_client, session_id).execute("localhost:3002/home")
        element_ids = FindElements.new(http_client, session_id).execute(using: LocationStrategy::CSS, value: "#words")
        element_ids.size.should eq(2)

        element_id = FindElement.new(http_client, session_id).execute(using: LocationStrategy::CSS, value: "[data-testid=\"item-0\"]")
        child_element_ids = FindElementsFromElement.new(http_client, session_id, element_id).execute(using: LocationStrategy::CSS, value: "p")
        child_element_ids.size.should eq(2)
        child_element_texts = child_element_ids.map do |child_element_id|
          GetElementText.new(http_client, session_id).execute(child_element_id)
        end
        child_element_texts.should contain("First Item")
        child_element_texts.should contain("Sub Text")
      end
    end
  end
end
