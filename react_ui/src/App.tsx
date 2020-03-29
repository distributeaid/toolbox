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
      <h1 className="text-2xl">Welcome</h1>
      <div>Step 1: create an account</div>
      <div>Step 2: check your email, get the code</div>
      <div>Step 3: Enter the verification code in the form below</div>
      <div>Step 4: Sign in</div>
      <div>
        (This is not the real process... Proof of concept to get auth between
        front / backend)
      </div>
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

            <input type="submit" value="Submit" />
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
      <ConfirmEmail></ConfirmEmail>
      <div>{username}</div>
      <div>{password}</div>
    </div>
  );
}

const ConfirmEmail = () => {
  const [username, setUsername] = React.useState("");
  const [verificationCode, setVerificationCode] = React.useState("");
  return (
    <div>
      Verify with code from email
      <form
        onSubmit={event => {
          event.preventDefault();
          Auth.confirmSignUp(username, verificationCode)
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
            Verification code (check email)
            <input
              className="border"
              onChange={event => setVerificationCode(event.currentTarget.value)}
              type="text"
              name="verification-code"
            ></input>
          </label>

          <input type="submit" value="Verify" />
        </div>
      </form>
    </div>
  );
};

export default App;
