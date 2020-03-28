import React from "react";
import "./App.css";
import Amplify, { Auth } from "aws-amplify";
import amplifyConfig from "./aws-exports";

Amplify.configure(amplifyConfig);

function App() {
  const [username, setUsername] = React.useState("");
  const [password, setPassword] = React.useState("");
  return (
    <div className="grid gap-5 p-5">
      <h1 className="text-2xl">Throw away sign up / Sign in</h1>
      <div className="mb">
        Sign in
        <form
          onSubmit={event => {
            event.preventDefault();
            Auth.signIn(username, password)
              .then(user => console.log(user))
              .catch(err => console.log(err));
          }}
        >
          <div className="grid">
            <label>
              Email
              <input
                className="border"
                name="username"
                onChange={event => setUsername(event.currentTarget.value)}
              ></input>
            </label>
            <label>
              Password
              <input
                className="border"
                onChange={event => setPassword(event.currentTarget.value)}
                type="password"
                name="password"
              ></input>
            </label>

            <input type="submit" value="Sign in" />
          </div>
        </form>
      </div>
      <div className="mb-5">
        Sign up
        <form
          onSubmit={event => {
            event.preventDefault();
            Auth.signUp({ username, password })
              .then(user => console.log(user))
              .catch(err => console.log(err));
          }}
        >
          <div className="grid">
            <label>
              Email
              <input
                className="border"
                name="username"
                onChange={event => setUsername(event.currentTarget.value)}
              ></input>
            </label>
            <label>
              Password
              <input
                className="border"
                onChange={event => setPassword(event.currentTarget.value)}
                type="password"
                name="password"
              ></input>
            </label>

            <input type="submit" value="Sign up" />
          </div>
        </form>
      </div>
      <div>{username}</div>
      <div>{password}</div>
    </div>
  );
}

export default App;
