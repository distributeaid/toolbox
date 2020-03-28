import React from "react";
import "./App.css";
import Amplify from "aws-amplify";

Amplify.configure({
  Auth: {
    identityPoolId: "us-east-2_W0AH6xG63", // Amazon Cognito Identity Pool ID
    region: "us-east-2" // Amazon Cognito Region
  }
});

function App() {
  const [username, setUsername] = React.useState("");
  const [password, setPassword] = React.useState("");
  return (
    <div>
      Throw this form away
      <form>
        <label>
          Username / email
          <input
            name="username"
            onChange={event => setUsername(event.currentTarget.value)}
          ></input>
        </label>
        <label>
          Password
          <input
            onChange={event => setPassword(event.currentTarget.value)}
            type="password"
            name="password"
          ></input>
        </label>
      </form>
      <div>{username}</div>
      <div>{password}</div>
    </div>
  );
}

export default App;
