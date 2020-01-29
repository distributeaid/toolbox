defmodule FerryWeb.LayoutView do
  use FerryWeb, :view

  def chat_meta(nil) do
    ""
  end

  def chat_meta(token) do
    ~E(
      <!-- Chat -->
      <meta name="chat:jwt" content="<%= token %>">
      <meta name="chat:context" content="general">
      <meta name="chat:apiKey" content="da2-ojgtsxntpnd4loyp67r6nm3lam">
      <meta name="chat:endpoint" content="https://uftb6vmdvze7nbnrfmk2ygipmm.appsync-api.eu-central-1.amazonaws.com/graphql">
    )
  end

  def chat_script(nil) do
    ""
  end

  def chat_script(token) do
    ~E(
      <!-- Chat -->
      <script src="https://cdnjs.cloudflare.com/ajax/libs/react/16.12.0/umd/react.production.min.js" defer></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/react-dom/16.11.0/umd/react-dom.production.min.js" defer></script>
      <script src="https://media.twiliocdn.com/sdk/js/chat/v3.3/twilio-chat.min.js" defer></script>
      <script src="https://twemoji.maxcdn.com/v/latest/twemoji.min.js" defer></script>
      <script src="https://github.com/distributeaid/chat-ui/releases/download/v1.14.0/distribute-aid-chat-ui.v1.14.0.js" defer></script>
      <script type="text/javascript">
        window.onload = (\) => {
          DAChat({
            context: document.querySelector("meta[name='chat:context']"\).getAttribute("content"\),
            apiKey: document.querySelector("meta[name='chat:apiKey']"\).getAttribute("content"\),
            apiEndpoint: document.querySelector("meta[name='chat:endpoint']"\).getAttribute("content"\),
            token: document.querySelector("meta[name='chat:jwt']"\).getAttribute("content"\),
          }\)
        }
      </script>
    )
  end

end
